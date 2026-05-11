using Ai_Fitness_Coach.Data;
using Ai_Fitness_Coach.DTOs;
using Ai_Fitness_Coach.Models;
using Microsoft.EntityFrameworkCore;

namespace Ai_Fitness_Coach.Services
{
    public class WorkoutService : IWorkoutService
    {
        private readonly ApplicationDbContext _context;

        public WorkoutService(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Dictionary<string, List<ExerciseDto>>> GetAllExercisesAsync()
        {
            var exercises = await _context.Exercises
                .Where(e => !e.IsDeleted)
                .ToListAsync();
            return exercises
                .GroupBy(e => e.ExerciseType.ToLower())
                .ToDictionary(
                    group => group.Key,
                    group => group.Select(e => new ExerciseDto
                    {
                        ExerciseId = e.Id,
                        Name = e.Name,
                        TargetMuscles = string.IsNullOrWhiteSpace(e.TargetMuscles)
                            ? new List<string>()
                            : e.TargetMuscles.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList(),
                        Equipments = string.IsNullOrWhiteSpace(e.Equipment)
                            ? new List<string>()
                            : e.Equipment.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList(),
                        ImageUrl = e.ImageUrl ?? "",
                        VideoUrl = e.VideoUrl ?? "",
                        ExerciseType = e.ExerciseType
                    }).ToList()
                );
        }

        public async Task<WorkoutPlanDto> CreateWorkoutPlanAsync(int userId, CreateWorkoutPlanRequest request)
        {
            var plan = new WorkoutPlan
            {
                Name = request.Name,
                UserId = userId,
                CreatedAt = DateTime.UtcNow,
                PlanExercises = request.ExerciseIds.Select(id => new WorkoutPlanExercise { ExerciseId = id }).ToList()
            };

            _context.WorkoutPlans.Add(plan);
            await _context.SaveChangesAsync();

            return await GetPlanByIdAsync(plan.Id);
        }

        public async Task<List<WorkoutPlanDto>> GetMyWorkoutsAsync(int userId)
        {
            var plans = await _context.WorkoutPlans
                .Include(p => p.PlanExercises)
                    .ThenInclude(pe => pe.Exercise)
                .Include(p => p.Sessions)
                .Where(p => p.UserId == userId)
                .OrderByDescending(p => p.CreatedAt)
                .ToListAsync();

            return plans.Select(plan => new WorkoutPlanDto
            {
                Id = plan.Id,
                Name = plan.Name,
                CreatedAt = plan.CreatedAt,
                UserId = userId,
                Progress = 0.0,
                SessionsCount = plan.Sessions.Count,
                Exercises = plan.PlanExercises.Select(pe => new ExerciseSessionDto
                {
                    ExerciseId = pe.Exercise.Id,
                    Name = pe.Exercise.Name,
                    TargetMuscles = (pe.Exercise.TargetMuscles ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries).ToList(),
                    Equipments = (pe.Exercise.Equipment ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries).ToList(),
                    ImageUrl = pe.Exercise.ImageUrl ?? "",
                    VideoUrl = pe.Exercise.VideoUrl ?? "",
                    ExerciseType = pe.Exercise.ExerciseType,
                    Completed = false,
                    Sets = new List<WorkoutSetDto>(),
                    CompletionPercentage = 0.0
                }).ToList()
            }).ToList();
        }

        private async Task<WorkoutPlanDto> GetPlanByIdAsync(int planId)
        {
            var plan = await _context.WorkoutPlans
                .Include(p => p.PlanExercises)
                    .ThenInclude(pe => pe.Exercise)
                .FirstOrDefaultAsync(p => p.Id == planId);

            if (plan == null) return null;

            return new WorkoutPlanDto
            {
                Id = plan.Id,
                Name = plan.Name,
                CreatedAt = plan.CreatedAt,
                UserId = plan.UserId,
                Exercises = plan.PlanExercises.Select(pe => new ExerciseSessionDto
                {
                    ExerciseId = pe.Exercise.Id,
                    Name = pe.Exercise.Name,
                    TargetMuscles = (pe.Exercise.TargetMuscles ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries).ToList(),
                    Equipments = (pe.Exercise.Equipment ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries).ToList(),
                    ImageUrl = pe.Exercise.ImageUrl ?? "",
                    VideoUrl = pe.Exercise.VideoUrl ?? "",
                    ExerciseType = pe.Exercise.ExerciseType,
                    Completed = false,
                    Sets = new List<WorkoutSetDto>(),
                    CompletionPercentage = 0.0
                }).ToList()
            };
        }
        public async Task<WorkoutSessionDto> SaveWorkoutSessionAsync(int userId, SaveSessionRequest request)
        {
            var session = new WorkoutSession
            {
                UserId = userId,
                WorkoutPlanId = request.WorkoutPlanId,
                IsCompleted = true
            };

            _context.WorkoutSessions.Add(session);
            await _context.SaveChangesAsync();

            double totalVolume = 0;
            int totalRepsOverall = 0;

            foreach (var reqEx in request.Exercises)
            {
                int setNumber = 1;
                foreach (var setDto in reqEx.Sets)
                {
                    var newSet = new WorkoutSet
                    {
                        ExerciseId = reqEx.ExerciseId,
                        WorkoutSessionId = session.Id,
                        SetNumber = setNumber++,
                        Reps = setDto.Reps,
                        Weight = setDto.Weight,
                        IsCompleted = setDto.IsCompleted
                    };

                    if (setDto.IsCompleted)
                    {
                        totalRepsOverall += setDto.Reps;
                        if (setDto.Weight.HasValue)
                        {
                            totalVolume += (double)(setDto.Weight.Value * setDto.Reps);
                        }
                    }

                    _context.WorkoutSets.Add(newSet);
                }
            }

            
            var analysis = new WorkoutAnalysis
            {
                SessionId = session.Id,
                TotalVolume = totalVolume,
                TotalReps = totalRepsOverall,
                CreatedAt = DateTime.UtcNow
            };

            _context.WorkoutAnalyses.Add(analysis);
            await _context.SaveChangesAsync();

            
            var planName = await _context.WorkoutPlans
                .Where(p => p.Id == request.WorkoutPlanId)
                .Select(p => p.Name)
                .FirstOrDefaultAsync() ?? "Custom Workout";

            
            return await MapSessionToDtoAsync(session.Id, request.WorkoutPlanId, planName, totalVolume, userId, request);
        }

        
        private async Task<WorkoutSessionDto> MapSessionToDtoAsync(int sessionId, int planId, string planName, double totalVolume, int userId, SaveSessionRequest request)
        {
            
            var sessionDto = new WorkoutSessionDto
            {
                Id = sessionId,
                WorkoutId = planId,
                WorkoutName = planName,
                PerformedAt = DateTime.UtcNow,
                UserId = userId,
                TotalVolume = totalVolume,
                Progress = 1.0,
                Exercises = new List<ExerciseSessionDto>()
            };

            
            var exerciseIds = request.Exercises.Select(e => e.ExerciseId).ToList();
            var exercisesDict = await _context.Exercises
                .Where(e => exerciseIds.Contains(e.Id))
                .ToDictionaryAsync(e => e.Id);

            
            foreach (var reqEx in request.Exercises)
            {
                
                if (!exercisesDict.TryGetValue(reqEx.ExerciseId, out var exercise))
                {
                    continue;
                }

                int totalSets = reqEx.Sets?.Count ?? 0;
                int completedSets = reqEx.Sets?.Count(s => s.IsCompleted) ?? 0;

                sessionDto.Exercises.Add(new ExerciseSessionDto
                {
                    ExerciseId = exercise.Id,
                    Name = exercise.Name,

                    
                    TargetMuscles = string.IsNullOrWhiteSpace(exercise.TargetMuscles)
                        ? new List<string>()
                        : exercise.TargetMuscles.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList(),

                    Equipments = string.IsNullOrWhiteSpace(exercise.Equipment)
                        ? new List<string>()
                        : exercise.Equipment.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList(),

                    ImageUrl = exercise.ImageUrl ?? "",
                    VideoUrl = exercise.VideoUrl ?? "",
                    ExerciseType = exercise.ExerciseType,

                    Completed = totalSets > 0 && completedSets == totalSets,
                    CompletionPercentage = totalSets == 0 ? 0 : (double)completedSets / totalSets,
                    Sets = reqEx.Sets ?? new List<WorkoutSetDto>()
                });
            }

            return sessionDto;
        }

        public async Task<ProgressOverviewDto> GetProgressOverviewAsync(int userId)
        {
            
            var sessions = await _context.WorkoutSessions
                .Where(s => s.UserId == userId && s.IsCompleted)
                .Include(s => s.WorkoutSets)
                    .ThenInclude(set => set.Exercise)
                .Include(s => s.WorkoutAnalysis)
                .Include(s => s.WorkoutPlan)
                .ToListAsync();

            
            var plans = await _context.WorkoutPlans
                .Where(p => p.UserId == userId)
                .Include(p => p.PlanExercises)
                .ToListAsync();

            
            if (!sessions.Any())
            {
                return new ProgressOverviewDto
                {
                    SavedWorkouts = plans.Count,
                    ExercisesInsidePlans = plans.Sum(p => p.PlanExercises.Count),
                    VolumeTrend = new List<VolumeTrendDto>()
                };
            }

            
            var firstSessionDate = sessions.Min(s => s.StartTime);
            var totalDaysActive = (DateTime.UtcNow - firstSessionDate).TotalDays;
            
            double totalWeeksCount = Math.Max(1, Math.Ceiling(totalDaysActive / 7.0));

            
            var topExercise = sessions.SelectMany(s => s.WorkoutSets)
                .GroupBy(set => set.Exercise.Name)
                .Select(g => new
                {
                    Name = g.Key,
                    TotalExVolume = g.Sum(set => (double)(set.Weight ?? 0) * set.Reps)
                })
                .OrderByDescending(x => x.TotalExVolume)
                .FirstOrDefault();

            
            var topWorkout = sessions
                .Where(s => s.WorkoutPlan != null)
                .GroupBy(s => s.WorkoutPlan!.Name)
                .Select(g => new
                {
                    Name = g.Key,
                    TotalPlanVolume = g.Sum(s => s.WorkoutAnalysis?.TotalVolume ?? 0)
                })
                .OrderByDescending(x => x.TotalPlanVolume)
                .FirstOrDefault();

            
            double totalSetsCount = sessions.SelectMany(s => s.WorkoutSets).Count();
            double completedSetsCount = sessions.SelectMany(s => s.WorkoutSets).Count(set => set.IsCompleted);

            
            return new ProgressOverviewDto
            {
                OverallCompletion = totalSetsCount == 0 ? 0 : (completedSetsCount / totalSetsCount) * 100,
                TotalVolume = sessions.Sum(s => s.WorkoutAnalysis?.TotalVolume ?? 0),
                AvgSessionVolume = sessions.Average(s => s.WorkoutAnalysis?.TotalVolume ?? 0),

                
                SessionsThisWeek = sessions.Count(s => s.StartTime >= DateTime.UtcNow.AddDays(-7)),
                WeeklyVolume = sessions.Where(s => s.StartTime >= DateTime.UtcNow.AddDays(-7))
                                       .Sum(s => s.WorkoutAnalysis?.TotalVolume ?? 0),

                
                AvgWeeklyVolume = sessions.Sum(s => s.WorkoutAnalysis?.TotalVolume ?? 0) / totalWeeksCount,

                TopVolumeExercise = topExercise?.Name ?? "None",
                TopWorkout = topWorkout?.Name ?? "None",

                SavedWorkouts = plans.Count,
                ExercisesInsidePlans = plans.Sum(p => p.PlanExercises.Count),

                
                
                VolumeTrend = sessions
                    .OrderBy(s => s.StartTime)
                    .TakeLast(7)
                    .Select(s => new VolumeTrendDto
                    {
                        DateLabel = s.StartTime.ToString("MMM dd"),
                        Volume = s.WorkoutAnalysis?.TotalVolume ?? 0
                    }).ToList()
            };
        }
        public async Task<bool> DeleteWorkoutPlanAsync(int planId, int userId)
        {
            
            var plan = await _context.WorkoutPlans
                .Include(p => p.PlanExercises)
                .FirstOrDefaultAsync(p => p.Id == planId && p.UserId == userId);

            if (plan == null)
            {
                return false;
            }

            
            var pastSessions = await _context.WorkoutSessions
                .Where(s => s.WorkoutPlanId == planId)
                .ToListAsync();

            
            foreach (var session in pastSessions)
            {
                session.WorkoutPlanId = null;
            }

            
            _context.WorkoutPlans.Remove(plan);
            await _context.SaveChangesAsync();

            return true;
        }
    }
}