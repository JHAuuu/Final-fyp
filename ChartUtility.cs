using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Windows.Forms.DataVisualization.Charting;

namespace fyp
{
    public static class ChartUtility
    {
        // Generates a pie chart with random colors
        public static Image GeneratePieChart(Dictionary<string, float> categoryPercentages)
        {
            int width = 400;
            int height = 400;
            var chartImage = new Bitmap(width, height);
            var graphics = Graphics.FromImage(chartImage);
            graphics.Clear(Color.White);

            // Calculate the total to determine the proportions
            float total = categoryPercentages.Values.Sum();
            float startAngle = 0;

            // Generate a pie chart with random colors
            foreach (var category in categoryPercentages)
            {
                float sweepAngle = (category.Value / total) * 360;
                using (Brush brush = new SolidBrush(GetRandomColor()))
                {
                    graphics.FillPie(brush, new Rectangle(50, 50, width - 100, height - 100), startAngle, sweepAngle);
                }
                startAngle += sweepAngle;
            }

            return chartImage;
        }

        // Generates a pie chart with labels showing category and percentage
        public static Image GeneratePieChartWithLabels(Dictionary<string, float> categoryPercentages)
        {
            var chart = new System.Windows.Forms.DataVisualization.Charting.Chart();
            chart.Width = 400; // Adjust the size as necessary
            chart.Height = 400;

            var chartArea = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            chart.ChartAreas.Add(chartArea);

            var series = new System.Windows.Forms.DataVisualization.Charting.Series
            {
                ChartType = System.Windows.Forms.DataVisualization.Charting.SeriesChartType.Pie,
                IsValueShownAsLabel = true, // Show the labels
                Label = "#VALX (#PERCENT{P0})", // Show category name and percentage
            };
            series.Points.DataBindXY(categoryPercentages.Keys, categoryPercentages.Values);
            chart.Series.Add(series);

            // Save the chart to a memory stream
            using (var memoryStream = new MemoryStream())
            {
                chart.SaveImage(memoryStream, System.Drawing.Imaging.ImageFormat.Png);
                return Image.FromStream(memoryStream);
            }
        }

        // Generates a random color
        private static Color GetRandomColor()
        {
            Random rand = new Random();
            return Color.FromArgb(rand.Next(256), rand.Next(256), rand.Next(256));
        }
    }
}