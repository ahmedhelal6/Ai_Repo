using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Ai_Fitness_Coach.Migrations
{
    /// <inheritdoc />
    public partial class workoutplanex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutPlan_Users_UserId",
                table: "WorkoutPlan");

            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutPlanExercise_Exercises_ExerciseId",
                table: "WorkoutPlanExercise");

            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutPlanExercise_WorkoutPlan_WorkoutPlanId",
                table: "WorkoutPlanExercise");

            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutSessions_WorkoutPlan_WorkoutPlanId",
                table: "WorkoutSessions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_WorkoutPlanExercise",
                table: "WorkoutPlanExercise");

            migrationBuilder.DropPrimaryKey(
                name: "PK_WorkoutPlan",
                table: "WorkoutPlan");

            migrationBuilder.RenameTable(
                name: "WorkoutPlanExercise",
                newName: "WorkoutPlanExercises");

            migrationBuilder.RenameTable(
                name: "WorkoutPlan",
                newName: "WorkoutPlans");

            migrationBuilder.RenameIndex(
                name: "IX_WorkoutPlanExercise_WorkoutPlanId",
                table: "WorkoutPlanExercises",
                newName: "IX_WorkoutPlanExercises_WorkoutPlanId");

            migrationBuilder.RenameIndex(
                name: "IX_WorkoutPlanExercise_ExerciseId",
                table: "WorkoutPlanExercises",
                newName: "IX_WorkoutPlanExercises_ExerciseId");

            migrationBuilder.RenameIndex(
                name: "IX_WorkoutPlan_UserId",
                table: "WorkoutPlans",
                newName: "IX_WorkoutPlans_UserId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_WorkoutPlanExercises",
                table: "WorkoutPlanExercises",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_WorkoutPlans",
                table: "WorkoutPlans",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutPlanExercises_Exercises_ExerciseId",
                table: "WorkoutPlanExercises",
                column: "ExerciseId",
                principalTable: "Exercises",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutPlanExercises_WorkoutPlans_WorkoutPlanId",
                table: "WorkoutPlanExercises",
                column: "WorkoutPlanId",
                principalTable: "WorkoutPlans",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutPlans_Users_UserId",
                table: "WorkoutPlans",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutSessions_WorkoutPlans_WorkoutPlanId",
                table: "WorkoutSessions",
                column: "WorkoutPlanId",
                principalTable: "WorkoutPlans",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutPlanExercises_Exercises_ExerciseId",
                table: "WorkoutPlanExercises");

            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutPlanExercises_WorkoutPlans_WorkoutPlanId",
                table: "WorkoutPlanExercises");

            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutPlans_Users_UserId",
                table: "WorkoutPlans");

            migrationBuilder.DropForeignKey(
                name: "FK_WorkoutSessions_WorkoutPlans_WorkoutPlanId",
                table: "WorkoutSessions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_WorkoutPlans",
                table: "WorkoutPlans");

            migrationBuilder.DropPrimaryKey(
                name: "PK_WorkoutPlanExercises",
                table: "WorkoutPlanExercises");

            migrationBuilder.RenameTable(
                name: "WorkoutPlans",
                newName: "WorkoutPlan");

            migrationBuilder.RenameTable(
                name: "WorkoutPlanExercises",
                newName: "WorkoutPlanExercise");

            migrationBuilder.RenameIndex(
                name: "IX_WorkoutPlans_UserId",
                table: "WorkoutPlan",
                newName: "IX_WorkoutPlan_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_WorkoutPlanExercises_WorkoutPlanId",
                table: "WorkoutPlanExercise",
                newName: "IX_WorkoutPlanExercise_WorkoutPlanId");

            migrationBuilder.RenameIndex(
                name: "IX_WorkoutPlanExercises_ExerciseId",
                table: "WorkoutPlanExercise",
                newName: "IX_WorkoutPlanExercise_ExerciseId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_WorkoutPlan",
                table: "WorkoutPlan",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_WorkoutPlanExercise",
                table: "WorkoutPlanExercise",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutPlan_Users_UserId",
                table: "WorkoutPlan",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutPlanExercise_Exercises_ExerciseId",
                table: "WorkoutPlanExercise",
                column: "ExerciseId",
                principalTable: "Exercises",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutPlanExercise_WorkoutPlan_WorkoutPlanId",
                table: "WorkoutPlanExercise",
                column: "WorkoutPlanId",
                principalTable: "WorkoutPlan",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_WorkoutSessions_WorkoutPlan_WorkoutPlanId",
                table: "WorkoutSessions",
                column: "WorkoutPlanId",
                principalTable: "WorkoutPlan",
                principalColumn: "Id");
        }
    }
}
