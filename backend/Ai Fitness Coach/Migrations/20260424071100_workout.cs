using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Ai_Fitness_Coach.Migrations
{
    /// <inheritdoc />
    public partial class workout : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DropColumn(
                name: "EndTime",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "Notes",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "StartTime",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "Category",
                table: "Exercises");

            migrationBuilder.RenameColumn(
                name: "MuscleGroup",
                table: "Exercises",
                newName: "ExerciseType");

            migrationBuilder.AddColumn<bool>(
                name: "IsCompleted",
                table: "WorkoutSets",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "IsCompleted",
                table: "WorkoutSessions",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "WorkoutPlanId",
                table: "WorkoutSessions",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Equipment",
                table: "Exercises",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "ImageUrl",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TargetMuscles",
                table: "Exercises",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "VideoUrl",
                table: "Exercises",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "WorkoutPlan",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UserId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkoutPlan", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WorkoutPlan_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WorkoutPlanExercise",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    WorkoutPlanId = table.Column<int>(type: "int", nullable: false),
                    ExerciseId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkoutPlanExercise", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WorkoutPlanExercise_Exercises_ExerciseId",
                        column: x => x.ExerciseId,
                        principalTable: "Exercises",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_WorkoutPlanExercise_WorkoutPlan_WorkoutPlanId",
                        column: x => x.WorkoutPlanId,
                        principalTable: "WorkoutPlan",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_WorkoutSessions_WorkoutPlanId",
                table: "WorkoutSessions",
                column: "WorkoutPlanId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkoutPlan_UserId",
                table: "WorkoutPlan",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkoutPlanExercise_ExerciseId",
                table: "WorkoutPlanExercise",
                column: "ExerciseId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkoutPlanExercise_WorkoutPlanId",
                table: "WorkoutPlanExercise",
                column: "WorkoutPlanId");

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutSessions_WorkoutPlan_WorkoutPlanId",
                table: "WorkoutSessions",
                column: "WorkoutPlanId",
                principalTable: "WorkoutPlan",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutSessions_WorkoutPlan_WorkoutPlanId",
                table: "WorkoutSessions");

            migrationBuilder.DropTable(
                name: "WorkoutPlanExercise");

            migrationBuilder.DropTable(
                name: "WorkoutPlan");

            migrationBuilder.DropIndex(
                name: "IX_WorkoutSessions_WorkoutPlanId",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "IsCompleted",
                table: "WorkoutSets");

            migrationBuilder.DropColumn(
                name: "IsCompleted",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "WorkoutPlanId",
                table: "WorkoutSessions");

            migrationBuilder.DropColumn(
                name: "Equipment",
                table: "Exercises");

            migrationBuilder.DropColumn(
                name: "ImageUrl",
                table: "Exercises");

            migrationBuilder.DropColumn(
                name: "TargetMuscles",
                table: "Exercises");

            migrationBuilder.DropColumn(
                name: "VideoUrl",
                table: "Exercises");

            migrationBuilder.RenameColumn(
                name: "ExerciseType",
                table: "Exercises",
                newName: "MuscleGroup");

            migrationBuilder.AddColumn<DateTime>(
                name: "EndTime",
                table: "WorkoutSessions",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Notes",
                table: "WorkoutSessions",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "StartTime",
                table: "WorkoutSessions",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "Category",
                table: "Exercises",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.InsertData(
                table: "Exercises",
                columns: new[] { "Id", "Category", "IsDeleted", "MuscleGroup", "Name" },
                values: new object[,]
                {
                    { 1, "Strength", false, "Legs", "Squat" },
                    { 2, "Strength", false, "Chest", "Bench Press" },
                    { 3, "Strength", false, "Back", "Deadlift" }
                });
        }
    }
}
