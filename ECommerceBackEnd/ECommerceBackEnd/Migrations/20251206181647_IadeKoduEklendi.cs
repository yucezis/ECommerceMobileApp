using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ECommerceBackEnd.Migrations
{
    /// <inheritdoc />
    public partial class IadeKoduEklendi : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "IadeKodu",
                table: "satislars",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IadeKodu",
                table: "satislars");
        }
    }
}
