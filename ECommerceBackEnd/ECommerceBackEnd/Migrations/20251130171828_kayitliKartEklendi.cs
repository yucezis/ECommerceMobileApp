using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ECommerceBackEnd.Migrations
{
    /// <inheritdoc />
    public partial class kayitliKartEklendi : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "KayitliKartlar",
                columns: table => new
                {
                    KartId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KartIsmi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    KartSahibi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    KartNumarasi = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SonKullanmaAy = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SonKullanmaYil = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    MusteriId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_KayitliKartlar", x => x.KartId);
                    table.ForeignKey(
                        name: "FK_KayitliKartlar_musteris_MusteriId",
                        column: x => x.MusteriId,
                        principalTable: "musteris",
                        principalColumn: "MusteriId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_KayitliKartlar_MusteriId",
                table: "KayitliKartlar",
                column: "MusteriId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "KayitliKartlar");
        }
    }
}
