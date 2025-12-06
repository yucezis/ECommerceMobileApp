using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ECommerceBackEnd.Migrations
{
    /// <inheritdoc />
    public partial class IadeNedeniEKlendi : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "IadeNedeni",
                table: "satislars",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IadeNedeni",
                table: "satislars");
        }
    }
}
