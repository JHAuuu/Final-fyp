using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Configuration;
using System.Web.UI;
using System.Globalization;
using System.Text.RegularExpressions;
using System.IO;
using System.Security.Cryptography;
using System.Reflection;
using System.Drawing;
using System.Drawing.Imaging;
using System.Net.Mail;

namespace fyp
{
    public class Common
    {        
        public static void LogToFile(string sMessage)
        {
            string sLogFolderPath = string.Empty;
            string sLogFileName = string.Empty;

            sLogFolderPath = ConfigurationManager.AppSettings["systemLogPath"] + "\\System Log";

            sLogFileName = sLogFolderPath + "\\" + DateTime.Now.ToString("yyyy") + "-" + DateTime.Now.ToString("MM") + "-" + DateTime.Now.ToString("dd") + ".txt";

            if (!Directory.Exists(sLogFolderPath))
            {
                Directory.CreateDirectory(sLogFolderPath);
            }

            using (StreamWriter writer = new StreamWriter(sLogFileName, true))
            {
                writer.WriteLine(String.Format("{0}: {1}", DateTime.Now.ToString("yyyy-MM-dd hh:mm:ss tt"), sMessage));
                writer.WriteLine();
                writer.Close();
            }
        }

        public static string FormatScriptValue(string sValue)
        {
            sValue = sValue.Replace("\\", "\\\\");
            sValue = sValue.Replace("'", "\\'");
            sValue = sValue.Replace("\"", "\\\"");
            sValue = sValue.Replace(System.Environment.NewLine, "\\n");

            return sValue.Trim();
        }

        public static string GenerateRandomString(int intLength, String sampleSpace)
        {
            StringBuilder res = new StringBuilder();
            byte[] uintBuffer = new byte[sizeof(uint)];
            using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
            {
                for (int i = 0; i < intLength; i++)
                {
                    rng.GetBytes(uintBuffer);
                    uint num = BitConverter.ToUInt32(uintBuffer, 0);
                    res.Append(sampleSpace[(int)(num % (uint)sampleSpace.Length)]);
                }
            }
            return res.ToString();
        }

        public static string GenerateAphaNumeric(int intLength)
        {
            return GenerateRandomString(intLength, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890");
        }

        public static string ConvertStringToHex(String input)
        {
            Byte[] stringBytes = System.Text.Encoding.Unicode.GetBytes(input);
            StringBuilder sbBytes = new StringBuilder(stringBytes.Length * 2);
            foreach (byte b in stringBytes)
            {
                sbBytes.AppendFormat("{0:X2}", b);
            }
            return sbBytes.ToString();
        }

        public static string ConvertHexToString(String hexInput)
        {
            try
            {
                int numberChars = hexInput.Length;
                byte[] bytes = new byte[numberChars / 2];
                for (int i = 0; i < numberChars; i += 2)
                {
                    bytes[i / 2] = Convert.ToByte(hexInput.Substring(i, 2), 16);
                }
                return System.Text.Encoding.Unicode.GetString(bytes);
            }
            catch (Exception)
            {
                return hexInput;
            }
        }

        public static DateTime? ParseDateFromDatabase(object rawDate)
        {
            return !string.IsNullOrEmpty(rawDate.ToString()) ? (DateTime?)DateTime.Parse(rawDate.ToString()) : null;
        }

        public static decimal ParseDecimalFromDatabase(object rawDecimal)
        {
            return !string.IsNullOrEmpty(rawDecimal.ToString()) ? Decimal.Parse(rawDecimal.ToString()) : 0;
        }

        public static Int32 ParseIntegerFromDatabase(object rawInteger)
        {
            return !string.IsNullOrEmpty(rawInteger.ToString()) ? Int32.Parse(rawInteger.ToString()) : 0;
        }

        public static bool IsValidEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return false;

            try
            {
                // Normalize the domain
                email = Regex.Replace(email, @"(@)(.+)$", DomainMapper,
                                      RegexOptions.None, TimeSpan.FromMilliseconds(200));

                // Examines the domain part of the email and normalizes it.
                string DomainMapper(Match match)
                {
                    // Use IdnMapping class to convert Unicode domain names.
                    var idn = new IdnMapping();

                    // Pull out and process domain name (throws ArgumentException on invalid)
                    var domainName = idn.GetAscii(match.Groups[2].Value);

                    return match.Groups[1].Value + domainName;
                }
            }
            catch (RegexMatchTimeoutException)
            {
                return false;
            }
            catch (ArgumentException)
            {
                return false;
            }

            try
            {
                return Regex.IsMatch(email,
                    @"^(?("")("".+?(?<!\\)""@)|(([0-9a-z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-z])@))" +
                    @"(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-z][-0-9a-z]*[0-9a-z]*\.)+[a-z0-9][\-a-z0-9]{0,22}[a-z0-9]))$",
                    RegexOptions.IgnoreCase, TimeSpan.FromMilliseconds(250));
            }
            catch (RegexMatchTimeoutException)
            {
                return false;
            }
        }

        public static bool IsValidPhone(string phone)
        {
            return Regex.IsMatch(phone, "^[0-9 \\+\\-]*$");
        }

        public static object FollowPropertyPath(object objProperty, string strPath)
        {
            if (objProperty == null)
                return string.Empty;
            else if (strPath.Contains('.'))
                return FollowPropertyPath(objProperty.GetType().GetProperty(strPath.Substring(0, strPath.IndexOf('.'))).GetValue(objProperty), strPath.Substring(strPath.IndexOf('.') + 1));
            else
                return objProperty.GetType().GetProperty(strPath).GetValue(objProperty);
        }

        public static PropertyInfo GetPropertyByPath(object objInstance, string strPath)
        {
            return GetPropertyByPath(objInstance, strPath.Split('.'));
        }

        public static PropertyInfo GetPropertyByPath(object objInstance, string[] strArraylisedPath)
        {
            if (strArraylisedPath.Length > 1)
                return GetPropertyByPath(objInstance.GetType().GetProperty(strArraylisedPath[0]).GetValue(objInstance), strArraylisedPath.Skip(1).ToArray());
            else
                return objInstance.GetType().GetProperty(strArraylisedPath[0]);
        }

        public static object GetPropertyInstanceByPath(object objInstance, string strPath)
        {
            return GetPropertyInstanceByPath(objInstance, strPath.Split('.'));
        }

        public static object GetPropertyInstanceByPath(object objInstance, string[] strArraylisedPath)
        {
            if (strArraylisedPath.Length > 1)
                return GetPropertyInstanceByPath(objInstance.GetType().GetProperty(strArraylisedPath[0]).GetValue(objInstance), strArraylisedPath.Skip(1).ToArray());
            else
                return objInstance;
        }

        public static bool IsEqualPassword(string sNewPassword, string sRetypeNewPassword)
        {
            if (sNewPassword.Trim().Equals(sRetypeNewPassword.Trim()))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public static bool IsEqualOTP(string sNewOTP, string sRetypeOTP)
        {
            if (sNewOTP.Trim().Equals(sRetypeOTP.Trim()))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public static bool IsEqual(object val1, object val2)
        {
            if ((val1 == null && val2 != null) || (val1 != null && val2 == null))
                return false;
            else if (val1 != null)
                return val1.Equals(val2);
            else if (val2 != null)
                return val2.Equals(val1);
            else
                return true;
        }

        public static bool IsEmpty(object val)
        {
            if (val == null)
                return true;
            else if (val is string)
                return string.IsNullOrWhiteSpace(val as string);
            else if (bool.TryParse(val.ToString(), out _))
                return val != (object)(default(bool));
            else if (decimal.TryParse(val.ToString(), out _))
                return val != (object)(default(decimal));
            else if (val.GetType().IsValueType)
                return Activator.CreateInstance(val.GetType()) == val;
            else
                return val == null;
        }

        public static DateTime[] GetAllDatesBetween(DateTime dteStartDate, DateTime dteEndDate)
        {
            return Enumerable.Range(0, Math.Abs((dteEndDate - dteStartDate).Days) + 1).Select(x => dteStartDate.AddDays(x * (dteEndDate >= dteStartDate ? 1 : -1))).ToArray();
        }

        public static int GetNumberOfNonBusinessDaysInBetween(DateTime dteStartDate, DateTime dteEndDate, DateTime[] dteBankHolidays)
        {
            return GetAllDatesBetween(dteStartDate, dteEndDate).Count(x => (new DayOfWeek[] { DayOfWeek.Saturday, DayOfWeek.Sunday }).Any(y => x.DayOfWeek == y) || (dteBankHolidays != null && dteBankHolidays.Contains(x)));
        }

        public static int GetNumberOfBusinessDaysInBetween(DateTime dteStartDate, DateTime dteEndDate, DateTime[] dteBankHolidays)
        {
            return (dteEndDate - dteStartDate).Days - GetNumberOfNonBusinessDaysInBetween(dteStartDate, dteEndDate, dteBankHolidays);
        }

        public static DateTime GetNextBusinessDayAfter(DateTime dteStartDate, uint intNoOfDays, DateTime[] dteBankHolidays, bool isCountOnlyBusinessDays)
        {
            DateTime dteResult = dteStartDate.AddDays(intNoOfDays + (isCountOnlyBusinessDays ? GetNumberOfNonBusinessDaysInBetween(dteStartDate, dteStartDate.AddDays(intNoOfDays), dteBankHolidays) : 0));

            while (isCountOnlyBusinessDays ? (GetNumberOfBusinessDaysInBetween(dteStartDate, dteResult, dteBankHolidays) < intNoOfDays) : ((new DayOfWeek[] { DayOfWeek.Saturday, DayOfWeek.Sunday }).Contains(dteResult.DayOfWeek) || (dteBankHolidays != null && dteBankHolidays.Contains(dteResult))))
                dteResult = dteResult.AddDays(1);

            return dteResult;
        }

        public static int GenerateRandomInteger(int intMinValue, int intMaxValue)
        {
            Random random = new Random();

            return random.Next(intMinValue, intMaxValue);
        }

        /*public static string GenerateQRCode(string strParameter, string strSessionToken)
        {
            string strResultQRCodeImage = string.Empty;

            //Generate QR Code
            BarcodeWriter qr = new BarcodeWriter
            {
                Format = ZXing.BarcodeFormat.QR_CODE,
                Options = new QrCodeEncodingOptions
                {
                    DisableECI = true,
                    CharacterSet = "UTF-8",
                    Width = 400,
                    Height = 400,
                }
            };

            //Bitmap result = new Bitmap(qr.Write(string.Format("{0}://{1}{2}/Admin/Payment.aspx?param={3}", HttpContext.Current.Request.Url.Scheme, HttpContext.Current.Request.Url.Host, (HttpContext.Current.Request.Url.Port == 80 ? "" : ":" + HttpContext.Current.Request.Url.Port), Encryption.EncryptToHex(strContactID + "|" + Session[Constant.SESSION_NAME_PAYMENT_CONTACT_TRANSACTION_TOKEN] as string))));

            //Bitmap result = new Bitmap(qr.Write(Encryption.EncryptToHex(strContactID + "|" + Session[Constant.SESSION_NAME_PAYMENT_CONTACT_TRANSACTION_TOKEN] as string)));
            //Bitmap result = new Bitmap(qr.Write(strContactID + "@" + Session[Constant.SESSION_NAME_PAYMENT_CONTACT_TRANSACTION_TOKEN] as string));
            Bitmap result = new Bitmap(qr.Write(Encryption.EncryptString(strParameter + "@" + strSessionToken)));

            // Set up string.
            Font stringFont = new Font("Arial", 12);
            //int margin = 10;

            //SizeF buildingNameSize;
            //using (Graphics g = Graphics.FromImage(new Bitmap(result.Width, result.Height)))
            //{
            //    buildingNameSize = g.MeasureString(ConfigurationManager.AppSettings["Building"], stringFont, result.Width);
            //}

            //SizeF visitDateSize;
            //using (Graphics g = Graphics.FromImage(new Bitmap(result.Width, result.Height)))
            //{
            //    visitDateSize = g.MeasureString(lblDate.Text, stringFont, result.Width);
            //}

            //Bitmap img = new Bitmap(result.Width, result.Height + (int)buildingNameSize.Height + (int)visitDateSize.Height + (margin * 2));
            Bitmap img = new Bitmap(result.Width, result.Height);

            using (Graphics g = Graphics.FromImage(img))
            {
                g.Clear(Color.White);
                //g.DrawImage(result, 0, buildingNameSize.Height + 10, result.Width, result.Height);
                g.DrawImage(result, 0, 10, result.Width, result.Height);
                //g.DrawString(ConfigurationManager.AppSettings["Building"], stringFont, Brushes.Black, new PointF((img.Width - buildingNameSize.Width) / 2, margin));
                //g.DrawString(lblDate.Text, stringFont, Brushes.Black, new PointF((img.Width - visitDateSize.Width) / 2, buildingNameSize.Height + result.Height + (margin * 2) - 10));
            }

            using (MemoryStream ms = new MemoryStream())
            {
                img.Save(ms, ImageFormat.Bmp);



                strResultQRCodeImage = "data:image/bmp;base64," + Convert.ToBase64String(ms.ToArray());
            }

            //HdQrFileName.Value = string.Format("QRCode_{0}_{1}_{2}.png", ConfigurationManager.AppSettings["Building"], lblDate.Text, txtName.Text);


            return strResultQRCodeImage;
        }*/

        public static void GetControlList<T>(ControlCollection controlCollection, List<T> resultCollection)
        where T : Control
        {
            foreach (Control control in controlCollection)
            {
                if (control is T)
                    resultCollection.Add((T)control);

                if (control.HasControls())
                    GetControlList(control.Controls, resultCollection);
            }
        }

        public static bool SendEmail(string toEmail, string toName, string ccEmail, string ccName, string subject, string emailBody)
        {
            string[] separatingStrings = { ";" };
            string[] arrTo = toEmail.Split(separatingStrings, System.StringSplitOptions.RemoveEmptyEntries);
            string[] arrToName = toName.Split(separatingStrings, System.StringSplitOptions.RemoveEmptyEntries);
            string[] arrCc = ccEmail.Split(separatingStrings, System.StringSplitOptions.RemoveEmptyEntries);
            string[] arrCcName = ccName.Split(separatingStrings, System.StringSplitOptions.RemoveEmptyEntries);

            int iCount = 0;
            bool bSend = false;
            MailMessage msg = new MailMessage();
            if (arrTo.Length > 0)
            {
                foreach (var to in arrTo)
                {
                    msg.To.Add(new MailAddress(to, arrToName[iCount]));
                    iCount += 1;
                }
            }

            iCount = 0;
            if (arrCc.Length > 0)
            {
                foreach (var cc in arrCc)
                {
                    msg.To.Add(new MailAddress(cc, arrCcName[iCount]));
                    iCount += 1;
                }
            }
            //if (ccEmail.Length>0) msg.CC.Add(new MailAddress(ccEmail, ccName));
            msg.From = new MailAddress(ConfigurationManager.AppSettings["emailFrom"], ConfigurationManager.AppSettings["emailFromName"]);
            msg.Subject = subject;
            msg.Body = emailBody;
            msg.IsBodyHtml = true;

            SmtpClient client = new SmtpClient();
            client.UseDefaultCredentials = false;
            client.Credentials = new System.Net.NetworkCredential(ConfigurationManager.AppSettings["emailCredentialUsername"], ConfigurationManager.AppSettings["emailCredentialPassword"]);
            client.Port = Convert.ToInt32(ConfigurationManager.AppSettings["emailPort"]);
            client.Host = ConfigurationManager.AppSettings["emailHost"];
            client.EnableSsl = true;

            try
            {
                client.Send(msg);
                LogToFile("Send email success. Email:(" + toEmail + ")");
                bSend = true;
            }
            catch (Exception ex)
            {
                LogToFile("Send email failed. Email:(" + toEmail + ") > Error: " + ex.ToString());
            }
            finally
            {
                if (msg != null)
                {
                    msg.Dispose();
                    msg = null;
                }

                if (client != null)
                {
                    client.Dispose();
                    client = null;
                }
            }
            return bSend;
        }

        public static bool assignTask(string role, string id, string jobType)
        {
            int retStatus = 0, intSuccess = 0;
            bool bAssign = false;
            DataTable dtTask = null;//, dtPIC = null;
            string sSQLTask = "select JobName, JobSequence from tbl_Job where [Status]='ACT' and [Role]='" + role + "' and JobType='" + jobType + "' order by JobSequence";
            string sSQLRole = "select UserRoleID from tbl_UserRole where UserRoleName='" + role + "'";
            string strROleId = "";
            string sSQLInsertTask = "insert into tbl_JobList select NEWID(), @Type, @Role, @Sequence, @Id, @Task, GETDATE(), null, null, ''";
            string[] arr = null;

            strROleId = DBHelper.ExecuteScalar(sSQLRole, null).ToString();

            dtTask = DBHelper.ExecuteQuery(sSQLTask, null);
            if (dtTask != null && dtTask.Rows.Count > 0)
            {
                foreach (DataRow dr in dtTask.Rows)
                {
                    arr = new string[10];
                    arr[0] = "@Type";
                    arr[1] = jobType;
                    arr[2] = "@Role";
                    arr[3] = strROleId;
                    arr[4] = "@Sequence";
                    arr[5] = dr["JobSequence"].ToString();
                    arr[6] = "@Task";
                    arr[7] = dr["JobName"].ToString();
                    arr[8] = "@Id";
                    arr[9] = id;

                    retStatus = DBHelper.ExecuteNonQuery(sSQLInsertTask, arr);
                    intSuccess += retStatus;
                }
                if (intSuccess == dtTask.Rows.Count)
                {
                    bAssign = true;
                }
            }

            return bAssign;
        }

        public static string generateReferralCode()
        {
            string alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            string small_alphabets = "abcdefghijklmnopqrstuvwxyz";
            string numbers = "1234567890";

            string characters = numbers;
            characters += alphabets + small_alphabets + numbers;
            int length = 8;
            string refCode = string.Empty;
            for (int i = 0; i < length; i++)
            {
                string character = string.Empty;
                do
                {
                    int index = new Random().Next(0, characters.Length);
                    character = characters.ToCharArray()[index].ToString();
                } while (refCode.IndexOf(character) != -1);
                refCode += character;
            }
            return refCode;
        }
    }
}