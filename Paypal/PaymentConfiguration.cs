using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using PayPal.Api;

namespace fyp
{
    public class PaymentConfiguration
    {

        static string ClientId;
        static string ClientSecret;
        static bool IsTest = true;

        // Static constructor for setting the readonly static members.
        static PaymentConfiguration()
        {
            if (IsTest)
            {
                // sandbox configuration
                ClientId = "Ae_CQsSzMHkPgl2H-N-Dxy08-j6rMzYtOww_0upVk_GQy1XDPy6MroILN6vli1EhRG_OcpkPNE__vKsl";
                ClientSecret = "EGS1tjwaq07544HMmKXoNAB_tdNO64Qbl_LbZNESgdHnx3zb7ka3RGvdAvZUNvKNosoeQ4_M012APrqL";
            }
            else
            {
                // live configuration
                ClientId = "AX--J5XW5vJwJhwnhQq6GdUAJZJ8sbpVh0cLlEbi1y-TWPLy278d96SeQUjbiTIH39yvproDBoIxae4c";
                ClientSecret = "EGp1gd9YPauf802EsK7yUJ07TdTPeEUfp4zMnzQjgA-sjMsBTOukxohDH_4OF51RxkUOHn0QCUD6kapG";
            }

        }

        // Create the configuration map that contains mode and other optional configuration details.
        public static Dictionary<string, string> GetConfig()
        {
            var config = new Dictionary<string, string>
            {
                {"mode", IsTest ? "sandbox" : "live"}
            };
            return config;
        }

        // Create accessToken
        private static string GetAccessToken()
        {
            // ###AccessToken
            // Retrieve the access token from
            // OAuthTokenCredential by passing in
            // ClientID and ClientSecret
            // It is not mandatory to generate Access Token on a per call basis.
            // Typically the access token can be generated once and
            // reused within the expiry window                
            string accessToken = new OAuthTokenCredential(ClientId, ClientSecret, GetConfig()).GetAccessToken();
            return accessToken;
        }

        // Returns APIContext object
        public static APIContext GetAPIContext(string accessToken = "")
        {
            // ### Api Context
            // Pass in a `APIContext` object to authenticate 
            // the call and to send a unique request id 
            // (that ensures idempotency). The SDK generates
            // a request id if you do not pass one explicitly. 
            var apiContext = new APIContext(string.IsNullOrEmpty(accessToken) ? GetAccessToken() : accessToken);
            apiContext.Config = GetConfig();

            // Use this variant if you want to pass in a request id  
            // that is meaningful in your application, ideally 
            // a order id.
            // String requestId = Long.toString(System.nanoTime();
            // APIContext apiContext = new APIContext(GetAccessToken(), requestId ));

            return apiContext;
        }

    }
}