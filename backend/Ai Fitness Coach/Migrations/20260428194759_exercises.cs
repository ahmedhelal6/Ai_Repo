using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Ai_Fitness_Coach.Migrations
{
    /// <inheritdoc />
    public partial class exercises : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Exercises",
                columns: new[] { "Id", "Equipment", "ExerciseType", "ImageUrl", "IsDeleted", "Name", "TargetMuscles", "VideoUrl" },
                values: new object[,]
                {
                    { 1, "barbell", "chest", "https://i.pinimg.com/736x/c6/4e/a9/c64ea9a4aeec242e709e0ee4f0e06c2e.jpg", false, "Bench Press", "chest", "https://youtube.com/shorts/0cXAp6WhSj4?si=j9wOwxSGDUij01_S" },
                    { 2, "dumbbell", "chest", "https://i.pinimg.com/736x/9b/48/27/9b48276aeba128d50f17087c7a24434e.jpg", false, "Incline Dumbbell Press", "upper_chest", "https://youtu.be/IP4oeKh1Sd4?si=CUqBXNoL7jCe5L0s" },
                    { 3, "barbell", "chest", "https://i.pinimg.com/736x/3a/f5/84/3af584e0bea6ed711905021002ebedcc.jpg", false, "Decline Press", "lower_chest", "https://youtu.be/LfyQBUKR8SE?si=7okiJuu9tLOu8sLj" },
                    { 4, "dumbbell", "chest", "https://i.pinimg.com/736x/ba/0d/37/ba0d37033b6e339039b15d551d294641.jpg", false, "Chest Fly", "chest", "https://youtu.be/eozdVDA78K0?si=1J1_PyoBVtu_Jwvp" },
                    { 5, "cable", "chest", "https://i.pinimg.com/736x/bd/d0/8c/bdd08cc009b9e4a4bc9c4d59ff686689.jpg", false, "Cable Crossover", "chest", "https://youtu.be/taI4XduLpTk?si=Q62_28A41GTPWvCl" },
                    { 6, "body_weight", "chest", "https://i.pinimg.com/1200x/4c/a0/cf/4ca0cf8fba6abc54ff11f3d42f7d4d9d.jpg", false, "Push Up", "chest", "https://youtu.be/WDIpL0pjun0?si=lyJuGjugdPChmFVf" },
                    { 7, "machine", "chest", "https://i.pinimg.com/736x/5a/d5/6d/5ad56d47c0d43c0accea1db38b5fd411.jpg", false, "Machine Press", "chest", "https://youtube.com/shorts/UH6y0fhbw8w?si=S2ZFGTMcNjDxAOUq" },
                    { 8, "dumbbell", "chest", "https://i.pinimg.com/1200x/17/4a/59/174a592203325454f658c920c5b8368d.jpg", false, "Dumbbell Pullover", "chest", "https://youtu.be/FK4rHfWKEac?si=KwpGQQkVgL3MVpPS" },
                    { 9, "machine", "chest", "https://i.pinimg.com/736x/1e/c5/84/1ec5845ed61d3ff2a96bbc678f601c16.jpg", false, "Incline Machine Press", "upper_chest", "https://youtu.be/VesHgJR14E8?si=0N4-gp9iKJD0Z_fc" },
                    { 10, "machine", "chest", "https://i.pinimg.com/736x/5c/25/79/5c257945695e265a496ba6e5119fd6e5.jpg", false, "Pec Deck Fly", "chest", "https://youtu.be/3jYo5cMU3d4?si=QSQXdXutC4gqwi7z" },
                    { 11, "cable", "back", "https://i.pinimg.com/736x/b1/63/1d/b1631da2844586e2c2795e8f7e83918a.jpg", false, "Lat Pulldown", "lats", "https://youtu.be/AOpi-p0cJkc?si=vdPRoav9ULsi9B74" },
                    { 12, "cable", "back", "https://i.pinimg.com/1200x/73/c4/9a/73c49a297f36321216c9b39b46b17a60.jpg", false, "Seated Row", "middle_back", "https://youtu.be/vwHG9Jfu4sw?si=SvWmWIEXsC_yNIU5" },
                    { 13, "body_weight", "back", "https://i.pinimg.com/736x/5c/17/5a/5c175ab10655a9c9990c3ad3b22d6f47.jpg", false, "Pull Up", "lats", "https://youtube.com/shorts/9rckBLbVe8c?si=-PsQso0hbZ_poD7K" },
                    { 14, "barbell", "back", "https://i.pinimg.com/736x/24/b0/f5/24b0f5a32471a84b692054b1a868e0b3.jpg", false, "Deadlift", "lower_back", "https://youtu.be/PUNxkzCjWNk?si=URLPsaJMweeOfLjI" },
                    { 15, "barbell", "back", "https://i.pinimg.com/736x/c3/fa/e1/c3fae1b0cc5da48d1cbff1ce6e7cb9d9.jpg", false, "T-Bar Row", "middle_back", "https://youtu.be/KDEl3AmZbVE?si=7MiEn6jUuObKoRaQ" },
                    { 16, "dumbbell", "back", "https://i.pinimg.com/1200x/29/95/9f/29959f92033e9a64554b25af535e0f2f.jpg", false, "One Arm Row", "lats", "https://youtu.be/PgpQ4-jHiq4?si=zLMfmyKcHmbDwWd3" },
                    { 17, "cable", "back", "https://i.pinimg.com/736x/5e/e6/4e/5ee64e2e9c1ae9b97022107ae16d26ab.jpg", false, "Straight Arm Pulldown", "lats", "https://youtu.be/wcVDItawocI?si=_eL8xscseTVsKlqD" },
                    { 18, "machine", "back", "https://i.pinimg.com/736x/4c/85/d0/4c85d0a72767b66665a97d10612681e6.jpg", false, "Machine Row", "middle_back", "https://youtu.be/TeFo51Q_Nsc?si=1XKX9L_CSsgJDRh-" },
                    { 19, "barbell", "back", "https://i.pinimg.com/736x/fa/52/4b/fa524ba0adc628dbe855033afadba6c2.jpg", false, "Bent Over Row", "middle_back", "https://youtu.be/-xlBxIMqh3A?si=wmGXzGbvIm9-7bHi" },
                    { 20, "machine", "back", "https://i.pinimg.com/736x/60/b7/27/60b7274d9f5b6bd990625b5da40c68db.jpg", false, "Chest Supported Row", "upper_back", "https://youtu.be/SC_Fg-fbzKQ?si=aDGG7TzdwbMfw73R" },
                    { 21, "barbell", "biceps", "https://i.pinimg.com/736x/0e/3d/47/0e3d47c212bd3cf141804f65d07d291b.jpg", false, "Barbell Curl", "biceps", "https://youtu.be/dDI8ClxRS04?si=vpEn5ec5wnEq3oQT" },
                    { 22, "dumbbell", "biceps", "https://i.pinimg.com/736x/2b/80/b8/2b80b84616a9dd930833911c4a663d3c.jpg", false, "Hammer Curl", "biceps", "https://youtu.be/0IAM2YtviQY?si=IkRA6U3-8vPvZ9V0" },
                    { 23, "barbell", "biceps", "https://i.pinimg.com/736x/ed/de/cc/eddecc0ce3200510cce0d549f418e1f9.jpg", false, "Preacher Curl", "biceps", "https://youtu.be/Gydpcouclx8?si=JgpylBbSDlK3OMWe" },
                    { 24, "dumbbell", "biceps", "https://i.pinimg.com/736x/e3/ef/c5/e3efc59257ca9277ac4129cca2c9578b.jpg", false, "Concentration Curl", "biceps", "https://youtu.be/VMbDQ8PZazY?si=Pgw2IVYimkpdk28k" },
                    { 25, "cable", "biceps", "https://i.pinimg.com/1200x/d1/ad/5e/d1ad5e7d75eabcf979160e9ec3a059f1.jpg", false, "Cable Curl", "biceps", "https://youtube.com/shorts/CrbTqNOlFgE?si=gbrpMjWOYRpDc1tW" },
                    { 26, "dumbbell", "biceps", "https://i.pinimg.com/736x/20/e2/7b/20e27b64fadf79ae83c878601df60ffd.jpg", false, "Spider Curl", "biceps", "https://youtu.be/nvufDW-MSQk?si=_dc4RvTzpjC_rnZe" },
                    { 31, "cable", "triceps", "https://i.pinimg.com/736x/39/63/cb/3963cbd3fca0d2623746f53fddee27c9.jpg", false, "Tricep Pushdown", "triceps", "https://youtu.be/-zLyUAo1gMw?si=yAKXcRkUzyZ_vZBo" },
                    { 32, "dumbbell", "triceps", "https://i.pinimg.com/1200x/e7/f1/1c/e7f11c9b787bd83c48b9f7136397cec4.jpg", false, "Overhead Extension", "triceps", "https://youtu.be/F3w6m0aENVQ?si=XbaI-UQKG3WwZ9kF" },
                    { 33, "body_weight", "triceps", "https://i.pinimg.com/736x/36/a7/86/36a786ad24672159f8797d1ad52905b5.jpg", false, "Bench Dips", "triceps", "https://youtu.be/5XkOdAtPn2Y?si=bdW6PS4GeQyYV1B_" },
                    { 34, "barbell", "triceps", "https://i.pinimg.com/736x/13/e7/69/13e769d0001345d8ceadae2867286fb7.jpg", false, "Skull Crusher", "triceps", "https://youtu.be/l3rHYPtMUo8?si=RYEpLy7eldsGnbDK" },
                    { 35, "barbell", "triceps", "https://i.pinimg.com/736x/25/d3/f0/25d3f0a34ddf948fc47f7c5d1dcd43f2.jpg", false, "Close Grip Bench", "triceps", "https://youtu.be/8o7jud9YlHU?si=dvZbVaKhVEic99OU" },
                    { 41, "barbell", "forearms", "https://i.pinimg.com/736x/5a/92/db/5a92db6bc9a75af5f8625aeff4e57c6d.jpg", false, "Wrist Curl", "forearms", "https://youtu.be/k6F6ugHyTcA?si=BY15MzTrO-ptiB4N" },
                    { 42, "dumbbell", "forearms", "https://i.pinimg.com/736x/2c/9f/c0/2c9fc0eab9d24737325d3362e2686f18.jpg", false, "Reverse Wrist Curl", "forearms", "https://youtu.be/osYPwlBiCRM?si=625NkFc9uH-Wdar_" },
                    { 43, "dumbbell", "forearms", "https://i.pinimg.com/736x/2b/80/b8/2b80b84616a9dd930833911c4a663d3c.jpg", false, "Hammer Curl (Forearms)", "brachioradialis", "https://youtu.be/-ncVKmrtXaM?si=MJal9zMKF7C8blK5" },
                    { 51, "dumbbell", "shoulders", "https://i.pinimg.com/736x/3a/33/c4/3a33c4e64884f1c5fafe8217c6e563b5.jpg", false, "Lateral Raise", "side_delts", "https://youtu.be/PzsMitRdI_8?si=jJKLyqNI3kiISGRc" },
                    { 52, "dumbbell", "shoulders", "https://i.pinimg.com/736x/95/83/0a/95830a2bf856831607d5f3749aa1d50a.jpg", false, "Front Raise", "front_delts", "https://youtu.be/ugPIPY7j-GM?si=9CdRWnFdQ3uwv0Xw" },
                    { 53, "dumbbell", "shoulders", "https://i.pinimg.com/736x/9a/bb/6c/9abb6ca4337f7c6eb11438fe0f3f2f35.jpg", false, "Shoulder Press", "shoulders", "https://youtu.be/0JfYxMRsUCQ?si=lm25qvcCLp-J36pQ" },
                    { 54, "dumbbell", "shoulders", "https://i.pinimg.com/736x/a4/14/18/a414187e689e9378d490ea5863682ce5.jpg", false, "Rear Delt Fly", "rear_delts", "https://youtu.be/nlkF7_2O_Lw?si=3Wqh4ZfJafBRV4n3" },
                    { 55, "barbell", "shoulders", "https://i.pinimg.com/1200x/e6/9d/c2/e69dc2fe577505490a8fc4a2830f198e.jpg", false, "Upright Row", "traps", "https://youtu.be/pNTPVN3FkSo?si=TvV_C0yUBLQfLLPX" },
                    { 61, "barbell", "legs", "https://i.pinimg.com/736x/d0/a7/ba/d0a7ba56416b59882350bb7287509f6b.jpg", false, "Barbell Squat", "quadriceps,glutes", "https://youtu.be/VZ90qWlfQUE?si=LGbTzbAB1HPT1v0P" },
                    { 62, "machine", "legs", "https://i.pinimg.com/736x/e0/52/59/e05259675f0a51b47e34832f11658b23.jpg", false, "Leg Press", "quadriceps", "https://youtu.be/Aq5uxXrXq7c?si=vlpD_LC2NhpNJKzc" },
                    { 63, "barbell", "legs", "https://i.pinimg.com/1200x/c4/78/ca/c478ca0a0c2fdfcad460a9d30d8cb644.jpg", false, "Romanian Deadlift", "hamstrings,glutes", "https://youtu.be/3VXmecChYYM?si=uwqxIG4wLg2jwCIK" },
                    { 64, "dumbbell", "legs", "https://i.pinimg.com/736x/ad/fd/58/adfd5843a204ab3edc730f621c9f0a9f.jpg", false, "Walking Lunge", "quadriceps,glutes", "https://youtu.be/DlhojghkaQ0?si=EfraGrmFD2oefoRS" },
                    { 65, "machine", "legs", "https://i.pinimg.com/736x/d6/18/8c/d6188c81ef3c4d531a7d6f089782d3f6.jpg", false, "Leg Extension", "quadriceps", "https://youtu.be/4ZDm5EbiFI8?si=rHR40-hEN9dsdS8J" },
                    { 66, "machine", "legs", "https://i.pinimg.com/736x/df/e6/54/dfe65427b2dee11c036df7c00f5969fc.jpg", false, "Leg Curl", "hamstrings", "https://youtu.be/t9sTSr-JYSs?si=xgSRknmAPZXRIrl1" },
                    { 67, "dumbbell", "legs", "https://i.pinimg.com/736x/c4/82/65/c482650b63f3c5d0c145f529ae1c1c6d.jpg", false, "Bulgarian Split Squat", "quadriceps,glutes", "https://youtu.be/DeCnHqrN22U?si=NjmILoT3hYh0byTl" },
                    { 68, "barbell", "legs", "https://i.pinimg.com/736x/00/c6/9f/00c69f716bf3d49a4d5e2fb99c2a89e4.jpg", false, "Hip Thrust", "glutes", "https://youtu.be/pUdIL5x0fWg?si=SqXn95gLxd2CR9mn" },
                    { 69, "machine", "legs", "https://i.pinimg.com/736x/59/f7/f7/59f7f7a2e2d085f072b38d6d96d93ca4.jpg", false, "Calf Raise", "calves", "https://youtube.com/shorts/baEXLy09Ncc?si=V2sXkPpE6XYopn0l" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
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

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 26);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 31);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 32);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 33);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 34);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 35);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 41);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 42);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 43);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 51);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 52);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 53);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 54);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 55);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 61);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 62);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 63);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 64);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 65);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 66);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 67);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 68);

            migrationBuilder.DeleteData(
                table: "Exercises",
                keyColumn: "Id",
                keyValue: 69);
        }
    }
}
