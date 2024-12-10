using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;

namespace fyp
{
    public class Rating
    {
        private static readonly MLContext mlContext = new MLContext();

        public static IEnumerable<RatingData> LoadRatingsFromDatabase()
        {
            string query = "SELECT PatronId, BookId, RateStarts FROM Rating";
            DataTable originalDt = DBHelper.ExecuteQuery(query);

            var ratings = new List<RatingData>();

            foreach (DataRow originalRow in originalDt.Rows)
            {
                RatingData rating = new RatingData
                {
                    UserId = Convert.ToUInt32(originalRow["PatronId"]),
                    BookId = Convert.ToUInt32(originalRow["BookId"]),
                    Label = Convert.ToSingle(originalRow["RateStarts"])
                };
                ratings.Add(rating);
            }

            return ratings;
        }

        public static ITransformer TrainModel(IEnumerable<RatingData> ratingData)
        {
            var data = mlContext.Data.LoadFromEnumerable(ratingData);

            var options = new MatrixFactorizationTrainer.Options
            {
                MatrixColumnIndexColumnName = nameof(RatingData.UserId),
                MatrixRowIndexColumnName = nameof(RatingData.BookId),
                LabelColumnName = nameof(RatingData.Label),
                NumberOfIterations = 20,
                ApproximationRank = 100
            };

            var pipeline = mlContext.Recommendation().Trainers.MatrixFactorization(options);

            return pipeline.Fit(data);
        }

        public static float PredictRating(ITransformer model, uint userId, uint bookId)
        {
            var predictionEngine = mlContext.Model.CreatePredictionEngine<RatingData, RatingPrediction>(model);

            var prediction = predictionEngine.Predict(
                new RatingData { UserId = userId, BookId = bookId }
            );

            return prediction.Score;
        }

        public static List<(int bookId, float score)> GetRecommendationsForUser(
            ITransformer model, uint userId, IEnumerable<uint> allBookIds, int numRecommendations = 5)
        {
            var recommendations = new List<(int bookId, float score)>();

            foreach (var bookId in allBookIds)
            {
                var score = PredictRating(model, userId, bookId);
                recommendations.Add(((int)bookId, score));
            }

            return recommendations
                   .OrderByDescending(r => r.score)
                   .Take(numRecommendations)
                   .ToList();
        }

        public static IEnumerable<uint> GetAllBookIdsFromDatabase()
        {
            string query = "SELECT DISTINCT BookId FROM Book"; // Adjust table/column names if necessary
            DataTable bookIdTable = DBHelper.ExecuteQuery(query);

            return bookIdTable.AsEnumerable().Select(row => Convert.ToUInt32(row["BookId"]));
        }
    }
}

public class RatingData
{
    [KeyType(100000)]
    public uint UserId { get; set; }
    [KeyType(100000)]
    public uint BookId { get; set; }
    public float Label { get; set; }
}

public class RatingPrediction
{
    public float Score { get; set; }
}
