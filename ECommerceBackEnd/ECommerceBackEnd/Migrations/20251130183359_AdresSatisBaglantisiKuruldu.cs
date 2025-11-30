using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ECommerceBackEnd.Migrations
{
    /// <inheritdoc />
    public partial class AdresSatisBaglantisiKuruldu : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TeslimatAdresiId",
                table: "satislars",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_satislars_TeslimatAdresiId",
                table: "satislars",
                column: "TeslimatAdresiId");

            migrationBuilder.AddForeignKey(
                name: "FK_satislars_Adresler_TeslimatAdresiId",
                table: "satislars",
                column: "TeslimatAdresiId",
                principalTable: "Adresler",
                principalColumn: "AdresId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_satislars_Adresler_TeslimatAdresiId",
                table: "satislars");

            migrationBuilder.DropIndex(
                name: "IX_satislars_TeslimatAdresiId",
                table: "satislars");

            migrationBuilder.DropColumn(
                name: "TeslimatAdresiId",
                table: "satislars");
        }
    }
}
