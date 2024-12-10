using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.Owin;
using Owin;
using Microsoft.AspNet.SignalR;
using Microsoft.Owin.Security.Cookies;

[assembly: OwinStartup(typeof(fyp.Startup))]
namespace fyp
{
    public class Startup
    {

        public void Configuration(IAppBuilder app)
        {
            var hubConfiguration = new HubConfiguration
            {
                EnableJSONP = true // Allows cross-origin requests
            };
            app.MapSignalR("/signalr", hubConfiguration);
            // Configure OWIN Cookie Authentication
            app.UseCookieAuthentication(new CookieAuthenticationOptions
            {
                AuthenticationType = "ApplicationCookie",
                LoginPath = new PathString("/Login.aspx"), // Redirect to login page
                ExpireTimeSpan = TimeSpan.FromMinutes(30), // Cookie expiration
                SlidingExpiration = true, // Extend cookie expiration on user activity
                CookieSecure = Microsoft.Owin.Security.Cookies.CookieSecureOption.SameAsRequest // Secure cookie only on HTTPS
            });
        }
    }
}