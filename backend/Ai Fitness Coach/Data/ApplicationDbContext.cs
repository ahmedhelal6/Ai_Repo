using Microsoft.EntityFrameworkCore;
using Ai_Fitness_Coach.Models;

namespace Ai_Fitness_Coach.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<WorkoutSession> WorkoutSessions { get; set; }
        public DbSet<WorkoutSet> WorkoutSets { get; set; }
        public DbSet<Exercise> Exercises { get; set; }
        public DbSet<ExerciseAnalysis> ExerciseAnalyses { get; set; }
        public DbSet<WorkoutAnalysis> WorkoutAnalyses { get; set; }
        public DbSet<WorkoutPlan> WorkoutPlans { get; set; }
        public DbSet<WorkoutPlanExercise> WorkoutPlanExercises { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // --- User ---
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .Property(u => u.Weight)
                .HasPrecision(18, 2);

            // --- WorkoutSession ---
            modelBuilder.Entity<WorkoutSession>()
                .HasOne(ws => ws.WorkoutAnalysis)
                .WithOne(wa => wa.WorkoutSession)
                .HasForeignKey<WorkoutAnalysis>(wa => wa.SessionId)
                .OnDelete(DeleteBehavior.Cascade);

            modelBuilder.Entity<WorkoutSession>()
                .HasMany(ws => ws.WorkoutSets)
                .WithOne(ws => ws.WorkoutSession)
                .HasForeignKey(ws => ws.WorkoutSessionId)
                .OnDelete(DeleteBehavior.Cascade);

            // --- WorkoutSet ---
            modelBuilder.Entity<WorkoutSet>()
                .Property(ws => ws.Weight)
                .HasPrecision(18, 2);

            // --- ExerciseAnalysis ---
            modelBuilder.Entity<ExerciseAnalysis>()
                .HasOne(ea => ea.WorkoutSession)
                .WithMany(ws => ws.ExerciseAnalyses)
                .HasForeignKey(ea => ea.WorkoutSessionId)
                .OnDelete(DeleteBehavior.NoAction);

            // --- Exercise ---
            modelBuilder.Entity<Exercise>()
                .HasQueryFilter(e => !e.IsDeleted);
            modelBuilder.Entity<WorkoutSet>()
                .HasQueryFilter(ws => !ws.Exercise.IsDeleted);

            modelBuilder.Entity<ExerciseAnalysis>()
                .HasQueryFilter(ea => !ea.Exercise.IsDeleted);
            modelBuilder.Entity<WorkoutPlanExercise>()
                .HasQueryFilter(wpe => !wpe.Exercise.IsDeleted);

            modelBuilder.Entity<WorkoutPlanExercise>()
                .HasOne(pe => pe.WorkoutPlan)
                .WithMany(p => p.PlanExercises)
                .HasForeignKey(pe => pe.WorkoutPlanId);
            modelBuilder.Entity<Exercise>().HasData(
        // --- CHEST (IDs 1-10) ---
        new Exercise { Id = 1, Name = "Bench Press", ExerciseType = "chest", TargetMuscles = "chest", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/c6/4e/a9/c64ea9a4aeec242e709e0ee4f0e06c2e.jpg", VideoUrl = "https://youtu.be/lWFknlOTbyM?si=L468WYToz1LvoUxa" },
        new Exercise { Id = 2, Name = "Incline Dumbbell Press", ExerciseType = "chest", TargetMuscles = "upper_chest", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/9b/48/27/9b48276aeba128d50f17087c7a24434e.jpg", VideoUrl = "https://youtu.be/IP4oeKh1Sd4?si=CUqBXNoL7jCe5L0s" },
        new Exercise { Id = 3, Name = "Decline Press", ExerciseType = "chest", TargetMuscles = "lower_chest", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/3a/f5/84/3af584e0bea6ed711905021002ebedcc.jpg", VideoUrl = "https://youtu.be/LfyQBUKR8SE?si=7okiJuu9tLOu8sLj" },
        new Exercise { Id = 4, Name = "Chest Fly", ExerciseType = "chest", TargetMuscles = "chest", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/ba/0d/37/ba0d37033b6e339039b15d551d294641.jpg", VideoUrl = "https://youtu.be/eozdVDA78K0?si=1J1_PyoBVtu_Jwvp" },
        new Exercise { Id = 5, Name = "Cable Crossover", ExerciseType = "chest", TargetMuscles = "chest", Equipment = "cable", ImageUrl = "https://i.pinimg.com/736x/bd/d0/8c/bdd08cc009b9e4a4bc9c4d59ff686689.jpg", VideoUrl = "https://youtu.be/taI4XduLpTk?si=Q62_28A41GTPWvCl" },
        new Exercise { Id = 6, Name = "Push Up", ExerciseType = "chest", TargetMuscles = "chest", Equipment = "body_weight", ImageUrl = "https://i.pinimg.com/1200x/4c/a0/cf/4ca0cf8fba6abc54ff11f3d42f7d4d9d.jpg", VideoUrl = "https://youtu.be/WDIpL0pjun0?si=lyJuGjugdPChmFVf" },
        new Exercise { Id = 7, Name = "Machine Press", ExerciseType = "chest", TargetMuscles = "chest", Equipment = "machine", ImageUrl = "https://i.pinimg.com/736x/5a/d5/6d/5ad56d47c0d43c0accea1db38b5fd411.jpg", VideoUrl = "https://youtu.be/zgP-UCKGe24?si=AnxW2mDH7ksGbvBv" },
        new Exercise { Id = 8, Name = "Dumbbell Pullover", ExerciseType = "chest", TargetMuscles = "chest", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/1200x/17/4a/59/174a592203325454f658c920c5b8368d.jpg", VideoUrl = "https://youtu.be/FK4rHfWKEac?si=KwpGQQkVgL3MVpPS" },
        new Exercise { Id = 9, Name = "Incline Machine Press", ExerciseType = "chest", TargetMuscles = "upper_chest", Equipment = "machine", ImageUrl = "https://i.pinimg.com/736x/1e/c5/84/1ec5845ed61d3ff2a96bbc678f601c16.jpg", VideoUrl = "https://youtu.be/VesHgJR14E8?si=0N4-gp9iKJD0Z_fc" },
        new Exercise { Id = 10, Name = "Pec Deck Fly", ExerciseType = "chest", TargetMuscles = "chest", Equipment = "machine", ImageUrl = "https://i.pinimg.com/736x/5c/25/79/5c257945695e265a496ba6e5119fd6e5.jpg", VideoUrl = "https://youtu.be/3jYo5cMU3d4?si=QSQXdXutC4gqwi7z" },

        // --- BACK (IDs 11-20) ---
        new Exercise { Id = 11, Name = "Lat Pulldown", ExerciseType = "back", TargetMuscles = "lats", Equipment = "cable", ImageUrl = "https://i.pinimg.com/736x/b1/63/1d/b1631da2844586e2c2795e8f7e83918a.jpg", VideoUrl = "https://youtu.be/AOpi-p0cJkc?si=vdPRoav9ULsi9B74" },
        new Exercise { Id = 12, Name = "Seated Row", ExerciseType = "back", TargetMuscles = "middle_back", Equipment = "cable", ImageUrl = "https://i.pinimg.com/1200x/73/c4/9a/73c49a297f36321216c9b39b46b17a60.jpg", VideoUrl = "https://youtu.be/vwHG9Jfu4sw?si=SvWmWIEXsC_yNIU5" },
        new Exercise { Id = 13, Name = "Pull Up", ExerciseType = "back", TargetMuscles = "lats", Equipment = "body_weight", ImageUrl = "https://i.pinimg.com/736x/5c/17/5a/5c175ab10655a9c9990c3ad3b22d6f47.jpg", VideoUrl = "https://youtu.be/eGo4IYlbE5g?si=ZEqwaIkV3gTYAhwK" },
        new Exercise { Id = 14, Name = "Deadlift", ExerciseType = "back", TargetMuscles = "lower_back", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/24/b0/f5/24b0f5a32471a84b692054b1a868e0b3.jpg", VideoUrl = "https://youtu.be/PUNxkzCjWNk?si=URLPsaJMweeOfLjI" },
        new Exercise { Id = 15, Name = "T-Bar Row", ExerciseType = "back", TargetMuscles = "middle_back", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/c3/fa/e1/c3fae1b0cc5da48d1cbff1ce6e7cb9d9.jpg", VideoUrl = "https://youtu.be/KDEl3AmZbVE?si=7MiEn6jUuObKoRaQ" },
        new Exercise { Id = 16, Name = "One Arm Row", ExerciseType = "back", TargetMuscles = "lats", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/1200x/29/95/9f/29959f92033e9a64554b25af535e0f2f.jpg", VideoUrl = "https://youtu.be/PgpQ4-jHiq4?si=zLMfmyKcHmbDwWd3" },
        new Exercise { Id = 17, Name = "Straight Arm Pulldown", ExerciseType = "back", TargetMuscles = "lats", Equipment = "cable", ImageUrl = "https://i.pinimg.com/736x/5e/e6/4e/5ee64e2e9c1ae9b97022107ae16d26ab.jpg", VideoUrl = "https://youtu.be/wcVDItawocI?si=_eL8xscseTVsKlqD" },
        new Exercise { Id = 18, Name = "Machine Row", ExerciseType = "back", TargetMuscles = "middle_back", Equipment = "machine", ImageUrl = "https://i.pinimg.com/736x/4c/85/d0/4c85d0a72767b66665a97d10612681e6.jpg", VideoUrl = "https://youtu.be/TeFo51Q_Nsc?si=1XKX9L_CSsgJDRh-" },
        new Exercise { Id = 19, Name = "Bent Over Row", ExerciseType = "back", TargetMuscles = "middle_back", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/fa/52/4b/fa524ba0adc628dbe855033afadba6c2.jpg", VideoUrl = "https://youtu.be/-xlBxIMqh3A?si=wmGXzGbvIm9-7bHi" },
        new Exercise { Id = 20, Name = "Chest Supported Row", ExerciseType = "back", TargetMuscles = "upper_back", Equipment = "machine", ImageUrl = "https://i.pinimg.com/736x/60/b7/27/60b7274d9f5b6bd990625b5da40c68db.jpg", VideoUrl = "https://youtu.be/SC_Fg-fbzKQ?si=aDGG7TzdwbMfw73R" },

        // --- BICEPS (IDs 21-30) ---
        new Exercise { Id = 21, Name = "Barbell Curl", ExerciseType = "biceps", TargetMuscles = "biceps", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/0e/3d/47/0e3d47c212bd3cf141804f65d07d291b.jpg", VideoUrl = "https://youtu.be/dDI8ClxRS04?si=vpEn5ec5wnEq3oQT" },
        new Exercise { Id = 22, Name = "Hammer Curl", ExerciseType = "biceps", TargetMuscles = "biceps", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/2b/80/b8/2b80b84616a9dd930833911c4a663d3c.jpg", VideoUrl = "https://youtu.be/0IAM2YtviQY?si=IkRA6U3-8vPvZ9V0" },
        new Exercise { Id = 23, Name = "Preacher Curl", ExerciseType = "biceps", TargetMuscles = "biceps", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/ed/de/cc/eddecc0ce3200510cce0d549f418e1f9.jpg", VideoUrl = "https://youtu.be/Gydpcouclx8?si=JgpylBbSDlK3OMWe" },
        new Exercise { Id = 24, Name = "Concentration Curl", ExerciseType = "biceps", TargetMuscles = "biceps", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/e3/ef/c5/e3efc59257ca9277ac4129cca2c9578b.jpg", VideoUrl = "https://youtu.be/VMbDQ8PZazY?si=Pgw2IVYimkpdk28k" },
        new Exercise { Id = 25, Name = "Cable Curl", ExerciseType = "biceps", TargetMuscles = "biceps", Equipment = "cable", ImageUrl = "https://i.pinimg.com/1200x/d1/ad/5e/d1ad5e7d75eabcf979160e9ec3a059f1.jpg", VideoUrl = "https://youtu.be/2MUEL4nL6hA?si=dfwz1AwLV4a0t3_J" },
        new Exercise { Id = 26, Name = "Spider Curl", ExerciseType = "biceps", TargetMuscles = "biceps", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/20/e2/7b/20e27b64fadf79ae83c878601df60ffd.jpg", VideoUrl = "https://youtu.be/nvufDW-MSQk?si=_dc4RvTzpjC_rnZe" },

        // --- TRICEPS (IDs 31-40) ---
        new Exercise { Id = 31, Name = "Tricep Pushdown", ExerciseType = "triceps", TargetMuscles = "triceps", Equipment = "cable", ImageUrl = "https://i.pinimg.com/736x/39/63/cb/3963cbd3fca0d2623746f53fddee27c9.jpg", VideoUrl = "https://youtu.be/-zLyUAo1gMw?si=yAKXcRkUzyZ_vZBo" },
        new Exercise { Id = 32, Name = "Overhead Extension", ExerciseType = "triceps", TargetMuscles = "triceps", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/1200x/e7/f1/1c/e7f11c9b787bd83c48b9f7136397cec4.jpg", VideoUrl = "https://youtu.be/F3w6m0aENVQ?si=XbaI-UQKG3WwZ9kF" },
        new Exercise { Id = 33, Name = "Bench Dips", ExerciseType = "triceps", TargetMuscles = "triceps", Equipment = "body_weight", ImageUrl = "https://i.pinimg.com/736x/36/a7/86/36a786ad24672159f8797d1ad52905b5.jpg", VideoUrl = "https://youtu.be/5XkOdAtPn2Y?si=bdW6PS4GeQyYV1B_" },
        new Exercise { Id = 34, Name = "Skull Crusher", ExerciseType = "triceps", TargetMuscles = "triceps", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/13/e7/69/13e769d0001345d8ceadae2867286fb7.jpg", VideoUrl = "https://youtu.be/l3rHYPtMUo8?si=RYEpLy7eldsGnbDK" },
        new Exercise { Id = 35, Name = "Close Grip Bench", ExerciseType = "triceps", TargetMuscles = "triceps", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/25/d3/f0/25d3f0a34ddf948fc47f7c5d1dcd43f2.jpg", VideoUrl = "https://youtu.be/8o7jud9YlHU?si=dvZbVaKhVEic99OU" },

        // --- FOREARMS (IDs 41-50) ---
        new Exercise { Id = 41, Name = "Wrist Curl", ExerciseType = "forearms", TargetMuscles = "forearms", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/5a/92/db/5a92db6bc9a75af5f8625aeff4e57c6d.jpg", VideoUrl = "https://youtu.be/k6F6ugHyTcA?si=BY15MzTrO-ptiB4N" },
        new Exercise { Id = 42, Name = "Reverse Wrist Curl", ExerciseType = "forearms", TargetMuscles = "forearms", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/2c/9f/c0/2c9fc0eab9d24737325d3362e2686f18.jpg", VideoUrl = "https://youtu.be/osYPwlBiCRM?si=625NkFc9uH-Wdar_" },
        new Exercise { Id = 43, Name = "Hammer Curl (Forearms)", ExerciseType = "forearms", TargetMuscles = "brachioradialis", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/2b/80/b8/2b80b84616a9dd930833911c4a663d3c.jpg", VideoUrl = "https://youtu.be/-ncVKmrtXaM?si=MJal9zMKF7C8blK5" },

        // --- SHOULDERS (IDs 51-60) ---
        new Exercise { Id = 51, Name = "Lateral Raise", ExerciseType = "shoulders", TargetMuscles = "side_delts", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/3a/33/c4/3a33c4e64884f1c5fafe8217c6e563b5.jpg", VideoUrl = "https://youtu.be/PzsMitRdI_8?si=jJKLyqNI3kiISGRc" },
        new Exercise { Id = 52, Name = "Front Raise", ExerciseType = "shoulders", TargetMuscles = "front_delts", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/95/83/0a/95830a2bf856831607d5f3749aa1d50a.jpg", VideoUrl = "https://youtu.be/ugPIPY7j-GM?si=9CdRWnFdQ3uwv0Xw" },
        new Exercise { Id = 53, Name = "Shoulder Press", ExerciseType = "shoulders", TargetMuscles = "shoulders", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/9a/bb/6c/9abb6ca4337f7c6eb11438fe0f3f2f35.jpg", VideoUrl = "https://youtu.be/0JfYxMRsUCQ?si=lm25qvcCLp-J36pQ" },
        new Exercise { Id = 54, Name = "Rear Delt Fly", ExerciseType = "shoulders", TargetMuscles = "rear_delts", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/a4/14/18/a414187e689e9378d490ea5863682ce5.jpg", VideoUrl = "https://youtu.be/nlkF7_2O_Lw?si=3Wqh4ZfJafBRV4n3" },
        new Exercise { Id = 55, Name = "Upright Row", ExerciseType = "shoulders", TargetMuscles = "traps", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/1200x/e6/9d/c2/e69dc2fe577505490a8fc4a2830f198e.jpg", VideoUrl = "https://youtu.be/pNTPVN3FkSo?si=TvV_C0yUBLQfLLPX" },

        // --- LEGS (IDs 61-80) ---
        new Exercise { Id = 61, Name = "Barbell Squat", ExerciseType = "legs", TargetMuscles = "quadriceps,glutes", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/d0/a7/ba/d0a7ba56416b59882350bb7287509f6b.jpg", VideoUrl = "https://youtu.be/VZ90qWlfQUE?si=LGbTzbAB1HPT1v0P" },
        new Exercise { Id = 62, Name = "Leg Press", ExerciseType = "legs", TargetMuscles = "quadriceps", Equipment = "machine", ImageUrl = "https://i.pinimg.com/736x/e0/52/59/e05259675f0a51b47e34832f11658b23.jpg", VideoUrl = "https://youtu.be/Aq5uxXrXq7c?si=vlpD_LC2NhpNJKzc" },
        new Exercise { Id = 63, Name = "Romanian Deadlift", ExerciseType = "legs", TargetMuscles = "hamstrings,glutes", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/1200x/c4/78/ca/c478ca0a0c2fdfcad460a9d30d8cb644.jpg", VideoUrl = "https://youtu.be/3VXmecChYYM?si=uwqxIG4wLg2jwCIK" },
        new Exercise { Id = 64, Name = "Walking Lunge", ExerciseType = "legs", TargetMuscles = "quadriceps,glutes", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/ad/fd/58/adfd5843a204ab3edc730f621c9f0a9f.jpg", VideoUrl = "https://youtu.be/DlhojghkaQ0?si=EfraGrmFD2oefoRS" },
        new Exercise { Id = 65, Name = "Leg Extension", ExerciseType = "legs", TargetMuscles = "quadriceps", Equipment = "machine", ImageUrl = "https://i.pinimg.com/736x/d6/18/8c/d6188c81ef3c4d531a7d6f089782d3f6.jpg", VideoUrl = "https://youtu.be/4ZDm5EbiFI8?si=rHR40-hEN9dsdS8J" },
        new Exercise { Id = 66, Name = "Leg Curl", ExerciseType = "legs", TargetMuscles = "hamstrings", Equipment = "machine", ImageUrl = "https://i.pinimg.com/736x/df/e6/54/dfe65427b2dee11c036df7c00f5969fc.jpg", VideoUrl = "https://youtu.be/t9sTSr-JYSs?si=xgSRknmAPZXRIrl1" },
        new Exercise { Id = 67, Name = "Bulgarian Split Squat", ExerciseType = "legs", TargetMuscles = "quadriceps,glutes", Equipment = "dumbbell", ImageUrl = "https://i.pinimg.com/736x/c4/82/65/c482650b63f3c5d0c145f529ae1c1c6d.jpg", VideoUrl = "https://youtu.be/DeCnHqrN22U?si=NjmILoT3hYh0byTl" },
        new Exercise { Id = 68, Name = "Hip Thrust", ExerciseType = "legs", TargetMuscles = "glutes", Equipment = "barbell", ImageUrl = "https://i.pinimg.com/736x/00/c6/9f/00c69f716bf3d49a4d5e2fb99c2a89e4.jpg", VideoUrl = "https://youtu.be/pUdIL5x0fWg?si=SqXn95gLxd2CR9mn" },
        new Exercise { Id = 69, Name = "Calf Raise", ExerciseType = "legs", TargetMuscles = "calves", Equipment = "machine", ImageUrl = "https://i.pinimg.com/736x/59/f7/f7/59f7f7a2e2d085f072b38d6d96d93ca4.jpg", VideoUrl = "https://youtu.be/SVtg-1loH4c?si=KxASCbCq0bdgE9IW" }
        );
        }
    }
}