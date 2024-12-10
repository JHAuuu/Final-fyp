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
    public class Encryption
    {
        private static int MIN_KEY_LENGTH = 32;

        private static readonly Func<string, string> AlphabeticCaseRandomiser = new Func<string, string>(str => new string(str.Select(x => (new Random()).Next() % 2 == 0 ? (char.IsUpper(x) ? x.ToString().ToLower().First() : x.ToString().ToUpper().First()) : x).ToArray()));

        public static string Encrypt(string clearText, string EncryptionKey)
        {
            byte[] clearBytes = Encoding.Unicode.GetBytes(clearText);
            Aes encryptor = Aes.Create();
            Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(EncryptionKey, new byte[] { 0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76 });
            encryptor.Key = pdb.GetBytes(32);
            encryptor.IV = pdb.GetBytes(16);
            MemoryStream ms = new MemoryStream();
            CryptoStream cs = new CryptoStream(ms, encryptor.CreateEncryptor(), CryptoStreamMode.Write);
            cs.Write(clearBytes, 0, clearBytes.Length);
            cs.Close();
            return Convert.ToBase64String(ms.ToArray());
        }

        public static string Decrypt(string cipherText, string EncryptionKey)
        {
            try
            {
                byte[] cipherBytes = Convert.FromBase64String(cipherText);
                Aes encryptor = Aes.Create();
                Rfc2898DeriveBytes pdb = new Rfc2898DeriveBytes(EncryptionKey, new byte[] { 0x49, 0x76, 0x61, 0x6e, 0x20, 0x4d, 0x65, 0x64, 0x76, 0x65, 0x64, 0x65, 0x76 });
                encryptor.Key = pdb.GetBytes(32);
                encryptor.IV = pdb.GetBytes(16);
                MemoryStream ms = new MemoryStream();
                CryptoStream cs = new CryptoStream(ms, encryptor.CreateDecryptor(), CryptoStreamMode.Write);
                cs.Write(cipherBytes, 0, cipherBytes.Length);
                cs.Close();
                return Encoding.Unicode.GetString(ms.ToArray());
            }
            catch (Exception ex)
            {
                // Handle or log the exception
                Console.WriteLine("Error during Base64 decoding: " + ex.Message);
                // Return a default value or null in case of an error
                return null;
            }
        }

        public static string Encrypt(string clearText)
        {
            string strKey = Common.GenerateAphaNumeric((new Random()).Next(MIN_KEY_LENGTH, MIN_KEY_LENGTH + 9));
            string str = Encrypt(clearText, strKey);
            string cipherText = EmbedCipherKeyToCipherText(str, strKey);
            try
            {
                if (Decrypt(cipherText) != clearText)
                {
                    return Encrypt(clearText);
                }
                else
                {
                    return cipherText;
                }
            }
            catch (FormatException)
            {
                return Encrypt(clearText);
            }
            catch (CryptographicException)
            {
                return Encrypt(clearText);
            }
        }

        public static string Decrypt(string cipherText)
        {
            try
            {
                ExtractCipherKeyFromCipherText(cipherText, out string extractedCipherText, out string extractedCipherKey);
                return Decrypt(extractedCipherText, extractedCipherKey);
            }
            catch (Exception)
            {
                return cipherText;
            }
        }

        public static string DecryptString(string encrString)
        {
            byte[] b;
            string decrypted;
            try
            {
                b = Convert.FromBase64String(encrString);
                decrypted = System.Text.ASCIIEncoding.ASCII.GetString(b);
            }
            catch (FormatException fe)
            {
                decrypted = "";
            }
            return decrypted;
        }

        public static string EncryptString(string strEncrypted)
        {
            byte[] b = System.Text.ASCIIEncoding.ASCII.GetBytes(strEncrypted);
            string encrypted = Convert.ToBase64String(b);
            return encrypted;
        }

        public static string EncryptToHex(string clearText)
        {
            return Common.ConvertStringToHex(Encrypt(clearText));
        }

        public static string DecryptFromHex(string cipherText)
        {
            return Decrypt(Common.ConvertHexToString(cipherText));
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

        private static string GenerateHashSalt(int size)
        {
            //Generate a cryptographic random number.
            RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider();
            byte[] buff = new byte[size];
            rng.GetBytes(buff);

            // Return a Base64 string representation of the random number.
            return Convert.ToBase64String(buff);
        }

        private static byte[] GenerateSaltedHash(byte[] plainText, byte[] salt)
        {
            HashAlgorithm algorithm = new SHA256Managed();

            byte[] plainTextWithSaltBytes =
              new byte[plainText.Length + salt.Length];

            for (int i = 0; i < plainText.Length; i++)
            {
                plainTextWithSaltBytes[i] = plainText[i];
            }
            for (int i = 0; i < salt.Length; i++)
            {
                plainTextWithSaltBytes[plainText.Length + i] = salt[i];
            }

            return algorithm.ComputeHash(plainTextWithSaltBytes);
        }

        private static bool CompareByteArrays(byte[] array1, byte[] array2)
        {
            if (array1.Length != array2.Length)
            {
                return false;
            }

            for (int i = 0; i < array1.Length; i++)
            {
                if (array1[i] != array2[i])
                {
                    return false;
                }
            }

            return true;
        }

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

        public static string GenerateSHA256String(string strInputString)
        {
            SHA256 sha256 = SHA256Managed.Create();
            byte[] bytes = Encoding.UTF8.GetBytes(strInputString);
            byte[] hash = sha256.ComputeHash(bytes);
            return GetStringFromHash(hash);
        }

        private static string GetStringFromHash(byte[] hash)
        {
            StringBuilder result = new StringBuilder();
            for (int i = 0; i < hash.Length; i++)
            {
                result.Append(hash[i].ToString("X2"));
            }
            return result.ToString().ToLower();
        }

        public static string AES256EncryptString(string plainText, byte[] key, byte[] iv)
        {
            // Instantiate a new Aes object to perform string symmetric encryption
            Aes encryptor = Aes.Create();

            encryptor.Mode = CipherMode.CBC;
            //encryptor.KeySize = 256;
            //encryptor.BlockSize = 128;
            //encryptor.Padding = PaddingMode.Zeros;

            // Set key and IV
            encryptor.Key = key;
            encryptor.IV = iv;

            // Instantiate a new MemoryStream object to contain the encrypted bytes
            MemoryStream memoryStream = new MemoryStream();

            // Instantiate a new encryptor from our Aes object
            ICryptoTransform aesEncryptor = encryptor.CreateEncryptor();

            // Instantiate a new CryptoStream object to process the data and write it to the 
            // memory stream
            CryptoStream cryptoStream = new CryptoStream(memoryStream, aesEncryptor, CryptoStreamMode.Write);

            // Convert the plainText string into a byte array
            byte[] plainBytes = Encoding.ASCII.GetBytes(plainText);

            // Encrypt the input plaintext string
            cryptoStream.Write(plainBytes, 0, plainBytes.Length);

            // Complete the encryption process
            cryptoStream.FlushFinalBlock();

            // Convert the encrypted data from a MemoryStream to a byte array
            byte[] cipherBytes = memoryStream.ToArray();

            // Close both the MemoryStream and the CryptoStream
            memoryStream.Close();
            cryptoStream.Close();

            // Convert the encrypted byte array to a base64 encoded string
            string cipherText = Convert.ToBase64String(cipherBytes, 0, cipherBytes.Length);

            // Return the encrypted data as a string
            return cipherText;
        }

        public static string AES256DecryptString(string cipherText, byte[] key, byte[] iv)
        {
            // Instantiate a new Aes object to perform string symmetric encryption
            Aes encryptor = Aes.Create();

            encryptor.Mode = CipherMode.CBC;
            //encryptor.KeySize = 256;
            //encryptor.BlockSize = 128;
            //encryptor.Padding = PaddingMode.Zeros;

            // Set key and IV
            encryptor.Key = key;
            encryptor.IV = iv;

            // Instantiate a new MemoryStream object to contain the encrypted bytes
            MemoryStream memoryStream = new MemoryStream();

            // Instantiate a new encryptor from our Aes object
            ICryptoTransform aesDecryptor = encryptor.CreateDecryptor();

            // Instantiate a new CryptoStream object to process the data and write it to the 
            // memory stream
            CryptoStream cryptoStream = new CryptoStream(memoryStream, aesDecryptor, CryptoStreamMode.Write);

            // Will contain decrypted plaintext
            string plainText = String.Empty;

            try
            {
                // Convert the ciphertext string into a byte array
                byte[] cipherBytes = Convert.FromBase64String(cipherText);

                // Decrypt the input ciphertext string
                cryptoStream.Write(cipherBytes, 0, cipherBytes.Length);

                // Complete the decryption process
                cryptoStream.FlushFinalBlock();

                // Convert the decrypted data from a MemoryStream to a byte array
                byte[] plainBytes = memoryStream.ToArray();

                // Convert the decrypted byte array to string
                plainText = Encoding.ASCII.GetString(plainBytes, 0, plainBytes.Length);
            }
            finally
            {
                // Close both the MemoryStream and the CryptoStream
                memoryStream.Close();
                cryptoStream.Close();
            }

            // Return the decrypted data as a string
            return plainText;
        }

        public static string AES256EncryptString(string strClearText)
        {
            string password = "XXX3sc3RLrpd17XXX";

            // Create sha256 hash
            SHA256 mySHA256 = SHA256Managed.Create();
            byte[] key = mySHA256.ComputeHash(Encoding.ASCII.GetBytes(password));

            // Create secret IV
            byte[] iv = new byte[16] { 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };

            return AES256EncryptString(strClearText, key, iv);
        }

        public static string AES256DecryptString(string strCiperText)
        {
            string password = "XXX3sc3RLrpd17XXX";

            // Create sha256 hash
            SHA256 mySHA256 = SHA256Managed.Create();
            byte[] key = mySHA256.ComputeHash(Encoding.ASCII.GetBytes(password));

            // Create secret IV
            byte[] iv = new byte[16] { 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 };

            return AES256DecryptString(strCiperText, key, iv);
        }
    }
}