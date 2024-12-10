using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace fyp
{
    public class encryption
    {
        private static int MIN_KEY_LENGTH = 32;
        private static readonly Func<string, string> AlphabeticCaseRandomiser = new Func<string, string>(str => new string(str.Select(x => (new Random()).Next() % 2 == 0 ? (char.IsUpper(x) ? x.ToString().ToLower().First() : x.ToString().ToUpper().First()) : x).ToArray()));

        public static string HashPassword(string strPlainTextPassword)
        {
            string strSalt = Common.GenerateAphaNumeric((new Random()).Next(MIN_KEY_LENGTH, MIN_KEY_LENGTH + 9));
            string strCipherTextPassword = GetHash(strPlainTextPassword, strSalt);

            return EmbedCipherKeyToCipherText(strCipherTextPassword, strSalt);
        }

        public static bool IsPasswordMatch(string strHashedPassword, string strPlainTextPassword)
        {
            ExtractCipherKeyFromCipherText(strHashedPassword, out string strHash, out string strSalt);
            return CompareHash(strPlainTextPassword, strHash, strSalt);
        }
        private static string GetHash(string password, string salt)
        {
            string strSaltedPassword;

            if (password.Length > salt.Length)
                strSaltedPassword = EmbedCipherKeyToCipherText(password, salt).Substring(6);
            else
                strSaltedPassword = EmbedCipherKeyToCipherText(salt, password).Substring(6);

            return Convert.ToBase64String((new SHA256Managed()).ComputeHash(Encoding.Unicode.GetBytes(strSaltedPassword)));
        }
        private static bool CompareHash(string attemptedPassword, string hashedPassword, string salt)
        {
            return hashedPassword == GetHash(attemptedPassword, salt);
        }

        private static void ExtractCipherKeyFromCipherText(string embeddedText, out string cipherText, out string cipherKey)
        {
            int intChunkSize = int.Parse(embeddedText.Substring(2, 2).ToUpper(), System.Globalization.NumberStyles.HexNumber) % 100;
            int intKeyLength = (int.Parse(embeddedText.Substring(4, 2).ToUpper(), System.Globalization.NumberStyles.HexNumber) % 10) + MIN_KEY_LENGTH;

            embeddedText = embeddedText.Substring(6);

            StringBuilder sbCipherText = new StringBuilder();
            StringBuilder sbCipherKey = new StringBuilder();

            for (int i = 0; i < intKeyLength; i++)
            {
                sbCipherText.Append(embeddedText.Substring(0, intChunkSize));
                sbCipherKey.Append(embeddedText.Substring(intChunkSize, 1));
                embeddedText = embeddedText.Substring(intChunkSize + 1);
            }

            sbCipherText.Append(embeddedText);

            cipherText = sbCipherText.ToString();
            cipherKey = sbCipherKey.ToString();
        }

        private static string EmbedCipherKeyToCipherText(string cipherText, string cipherKey)
        {
            StringBuilder sb = new StringBuilder();

            int intChuckSize = (int)Math.Floor((double)(cipherText.Length / (cipherKey.Length + 1)));

            for (int i = 0; i < cipherKey.Length; i++)
            {
                sb.Append(cipherText.Substring(0, intChuckSize) + cipherKey[i]);
                cipherText = cipherText.Substring(intChuckSize);
            }

            sb.Append(cipherText);

            return Common.GenerateAphaNumeric(2) + AlphabeticCaseRandomiser(((new Random()).Next(0, 2) * 100 + intChuckSize).ToString("X2") + ((new Random()).Next(0, 24) * 10 + ((cipherKey.Length - (MIN_KEY_LENGTH - 10)) % 10)).ToString("X2")) + sb.ToString();
        }
    }
}