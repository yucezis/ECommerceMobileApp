using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ECommerceBackEnd.Migrations
{
    /// <inheritdoc />
    public partial class test : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "admins",
                columns: table => new
                {
                    AdminId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KullaniciAdi = table.Column<string>(type: "VARCHAR(10)", maxLength: 10, nullable: false),
                    Sifre = table.Column<string>(type: "VARCHAR(10)", maxLength: 10, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_admins", x => x.AdminId);
                });

            migrationBuilder.CreateTable(
                name: "kategoris",
                columns: table => new
                {
                    KategoriID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KategoriAdi = table.Column<string>(type: "VARCHAR(30)", maxLength: 30, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_kategoris", x => x.KategoriID);
                });

            migrationBuilder.CreateTable(
                name: "musteris",
                columns: table => new
                {
                    MusteriId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MusteriAdi = table.Column<string>(type: "VARCHAR(30)", maxLength: 30, nullable: false),
                    MusteriSoyadi = table.Column<string>(type: "VARCHAR(30)", maxLength: 30, nullable: false),
                    MusteriSehir = table.Column<string>(type: "VARCHAR(15)", maxLength: 15, nullable: false),
                    MusteriTelNo = table.Column<string>(type: "VARCHAR(10)", maxLength: 10, nullable: false),
                    MusteriMail = table.Column<string>(type: "VARCHAR(50)", maxLength: 50, nullable: false),
                    MusteriSifre = table.Column<string>(type: "VARCHAR(50)", maxLength: 50, nullable: false),
                    Durum = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_musteris", x => x.MusteriId);
                });

            migrationBuilder.CreateTable(
                name: "uruns",
                columns: table => new
                {
                    UrunId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UrunAdi = table.Column<string>(type: "VARCHAR(30)", maxLength: 30, nullable: true),
                    UrunMarka = table.Column<string>(type: "VARCHAR(30)", maxLength: 30, nullable: true),
                    UrunYazar = table.Column<string>(type: "VARCHAR(250)", maxLength: 250, nullable: true),
                    UrunStok = table.Column<short>(type: "smallint", nullable: false),
                    UrunSatisFiyati = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    UrunStokDurum = table.Column<bool>(type: "bit", nullable: false),
                    UrunGorsel = table.Column<string>(type: "VARCHAR(250)", maxLength: 250, nullable: true),
                    KategoriID = table.Column<int>(type: "int", nullable: false),
                    Durum = table.Column<bool>(type: "bit", nullable: false),
                    IndirimliFiyat = table.Column<decimal>(type: "decimal(18,2)", nullable: true),
                    Aciklama = table.Column<string>(type: "NVARCHAR(MAX)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_uruns", x => x.UrunId);
                    table.ForeignKey(
                        name: "FK_uruns_kategoris_KategoriID",
                        column: x => x.KategoriID,
                        principalTable: "kategoris",
                        principalColumn: "KategoriID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "satislars",
                columns: table => new
                {
                    SatislarId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Tarih = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Adet = table.Column<int>(type: "int", nullable: false),
                    Fiyat = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    ToplamTutar = table.Column<decimal>(type: "decimal(18,2)", nullable: false),
                    UrunId = table.Column<int>(type: "int", nullable: false),
                    MusteriId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_satislars", x => x.SatislarId);
                    table.ForeignKey(
                        name: "FK_satislars_musteris_MusteriId",
                        column: x => x.MusteriId,
                        principalTable: "musteris",
                        principalColumn: "MusteriId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_satislars_uruns_UrunId",
                        column: x => x.UrunId,
                        principalTable: "uruns",
                        principalColumn: "UrunId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_satislars_MusteriId",
                table: "satislars",
                column: "MusteriId");

            migrationBuilder.CreateIndex(
                name: "IX_satislars_UrunId",
                table: "satislars",
                column: "UrunId");

            migrationBuilder.CreateIndex(
                name: "IX_uruns_KategoriID",
                table: "uruns",
                column: "KategoriID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "admins");

            migrationBuilder.DropTable(
                name: "satislars");

            migrationBuilder.DropTable(
                name: "musteris");

            migrationBuilder.DropTable(
                name: "uruns");

            migrationBuilder.DropTable(
                name: "kategoris");
        }
    }
}
