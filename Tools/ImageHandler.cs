using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Web;
using System.IO;
namespace fyp
{
    public class ImageHandler
    {
        public static String GetImage(byte[] imageData)
        {
            if (imageData == null || imageData.Length == 0)
            {
                throw new InvalidOperationException("No image data available.");
            }

                string contentType = "image/jpeg";
                string imageSrc = string.Format("data:{0};base64,{1}", contentType, Convert.ToBase64String(imageData));
                return imageSrc;
            
        }

    }
}