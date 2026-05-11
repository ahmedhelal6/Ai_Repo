using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ai_Fitness_Coach.Migrations
{
    /// <inheritdoc />
    public partial class exe : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 1,
                column: "VideoUrl",
                value: "https://youtu.be/lWFknlOTbyM?si=L468WYToz1LvoUxa");

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 7,
                column: "VideoUrl",
                value: "https://youtu.be/zgP-UCKGe24?si=AnxW2mDH7ksGbvBv");

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 13,
                column: "VideoUrl",
                value: "https://youtu.be/eGo4IYlbE5g?si=ZEqwaIkV3gTYAhwK");

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 25,
                column: "VideoUrl",
                value: "https://youtu.be/2MUEL4nL6hA?si=dfwz1AwLV4a0t3_J");

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 69,
                column: "VideoUrl",
                value: "https://youtu.be/SVtg-1loH4c?si=KxASCbCq0bdgE9IW");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 1,
                column: "VideoUrl",
                value: "https://youtube.com/shorts/0cXAp6WhSj4?si=j9wOwxSGDUij01_S");

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 7,
                column: "VideoUrl",
                value: "https://youtube.com/shorts/UH6y0fhbw8w?si=S2ZFGTMcNjDxAOUq");

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 13,
                column: "VideoUrl",
                value: "https://youtube.com/shorts/9rckBLbVe8c?si=-PsQso0hbZ_poD7K");

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 25,
                column: "VideoUrl",
                value: "https://youtube.com/shorts/CrbTqNOlFgE?si=gbrpMjWOYRpDc1tW");

            migrationBuilder.UpdateData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 69,
                column: "VideoUrl",
                value: "https://youtube.com/shorts/baEXLy09Ncc?si=V2sXkPpE6XYopn0l");
        }
    }
}
