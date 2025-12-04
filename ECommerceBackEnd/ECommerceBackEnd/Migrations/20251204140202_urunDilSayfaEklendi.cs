using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ECommerceBackEnd.Migrations
{
    /// <inheritdoc />
    public partial class urunDilSayfaEklendi : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "UrunDil",
                table: "uruns",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "UrunSayfa",
                table: "uruns",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "UrunDil",
                table: "uruns");

            migrationBuilder.DropColumn(
                name: "UrunSayfa",
                table: "uruns");
        }
    }
}
