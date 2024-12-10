<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="401Unauthorized.aspx.cs" Inherits="fyp.error._401Unauthorized" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Error</title>
    <link rel="stylesheet" href="css/unauthorized.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="content">
                <h1>401 Unauthorized</h1>
                <p>Oops! You are not authorized to view this page. Please log in to access this resource.</p>
                <a href="../Login.aspx" class="btn-login">Go to Login</a>
            </div>
        </div>
    </form>
</body>
</html>
