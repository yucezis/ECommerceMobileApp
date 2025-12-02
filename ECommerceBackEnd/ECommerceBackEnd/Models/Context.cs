using Microsoft.EntityFrameworkCore;

namespace ECommerceBackEnd.Models
{
    public class Context: DbContext
    {
        public Context(DbContextOptions<Context> options) : base(options) { }

        public DbSet<Admin> admins { get; set; }
        public DbSet<Musteri> musteris { get; set; }
        public DbSet<Kategori> kategoris { get; set; }
        public DbSet<Satislar> satislars { get; set; }
        public DbSet<Urun> uruns { get; set; }
        public DbSet<Adres> Adresler { get; set; }
        public DbSet<KayitliKart> KayitliKartlar { get; set; }
        public DbSet<Mesaj> Mesajlar { get; set; }
        public DbSet<Degerlendirme> degerlendirmes { get; set; }

    }
}
