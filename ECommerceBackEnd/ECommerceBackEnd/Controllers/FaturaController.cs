using ECommerceBackEnd.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace ECommerceBackEnd.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FaturaController : ControllerBase
    {
        private readonly Context _context;

        public FaturaController(Context context)
        {
            _context = context;
            QuestPDF.Settings.License = LicenseType.Community;
        }

        [HttpGet("Olustur/{siparisNo}")]
        public IActionResult Olustur(string siparisNo)
        {
            var siparisUrunleri = _context.satislars
                .Include(x => x.Urun)
                .Include(x => x.Musteri)
                .Include(x => x.TeslimatAdresi)
                .Where(x => x.SiparisNo == siparisNo)
                .ToList();

            if (!siparisUrunleri.Any()) return NotFound("Sipariş bulunamadı.");

            var ilkKayit = siparisUrunleri.First();
            var musteri = ilkKayit.Musteri;
            var adres = ilkKayit.TeslimatAdresi;

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(2, Unit.Centimetre);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(12));

                    page.Header()
                        .Text($"FATURA - #{siparisNo}")
                        .SemiBold().FontSize(24).FontColor(Colors.Blue.Medium);

                    page.Content()
                        .PaddingVertical(1, Unit.Centimetre)
                        .Column(x =>
                        {
                            x.Item().Text($"Sayın {musteri.MusteriAdi} {musteri.MusteriSoyadi}");
                            x.Item().Text($"Tarih: {ilkKayit.Tarih:dd.MM.yyyy HH:mm}");
                            if (adres != null)
                                x.Item().Text($"Adres: {adres.AcikAdres} {adres.Ilce}/{adres.Sehir}");

                            x.Item().PaddingVertical(10).LineHorizontal(1).LineColor(Colors.Grey.Lighten1);

                            x.Item().Row(header =>
                            {
                                header.RelativeItem(3).Text("Ürün Adı").Bold();
                                header.RelativeItem(1).Text("Adet").Bold().AlignRight();
                                header.RelativeItem(1).Text("Birim Fiyat").Bold().AlignRight();
                                header.RelativeItem(1).Text("Toplam").Bold().AlignRight();
                            });

                            foreach (var urun in siparisUrunleri)
                            {
                                x.Item().BorderBottom(1).BorderColor(Colors.Grey.Lighten2).PaddingVertical(5).Row(row =>
                                {
                                    row.RelativeItem(3).Text(urun.Urun?.UrunAdi ?? "Silinmiş Ürün");
                                    row.RelativeItem(1).Text(urun.Adet.ToString()).AlignRight();
                                    row.RelativeItem(1).Text($"{urun.Fiyat:F2} TL").AlignRight();
                                    row.RelativeItem(1).Text($"{urun.Adet * urun.Fiyat:F2} TL").AlignRight();
                                });
                            }

                            var genelToplam = siparisUrunleri.Sum(u => u.Adet * u.Fiyat);
                            x.Item().PaddingTop(10).AlignRight().Text($"GENEL TOPLAM: {genelToplam:F2} TL").FontSize(16).Bold().FontColor(Colors.Red.Medium);
                        });

                    page.Footer()
                        .AlignCenter()
                        .Text(x =>
                        {
                            x.Span("Books E-Ticaret A.Ş. ");
                            x.CurrentPageNumber();
                        });
                });
            });

            byte[] pdfBytes = document.GeneratePdf();
            return File(pdfBytes, "application/pdf", $"Fatura_{siparisNo}.pdf");
        }
    }
}