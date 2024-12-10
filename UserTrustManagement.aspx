<%@ Page Title="UserTrustManagement" MasterPageFile="~/Master/DashMasterPage.Master" Language="C#" AutoEventWireup="true" CodeBehind="UserTrustManagement.aspx.cs" Inherits="fyp.UserTrustManagement" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .title {
            display: flex;
            justify-content: space-between;
        }

        .user-list {
            margin-top: 8px;
            background-color: #fff;
            width: 100%;
            border-collapse: collapse;
            border-radius: 5px;
            border-style: hidden;
            box-shadow: 0 0 0 2px #666;
        }

            .user-list td,
            .user-list th {
                padding: 1rem;
                font-weight: 600;
                text-align: center;
                border-bottom: 1px solid #ddd;
            }

            .user-list th {
                border-bottom: 2px solid #000000;
            }


            .user-list .action-icons a {
                text-decoration: none;
                font-size: 18px;
                margin: 0 5px;
                color: #333;
            }

        .popup-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(0, 0, 0, 0.6); /* Dark semi-transparent background */
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
}

/* Popup styling */
.popup {
    background-color: white;
    border-radius: 8px;
    padding: 20px;
    width: 500px;
    max-width: 90%;
    box-shadow: 0px 4px 20px rgba(0, 0, 0, 0.2);
    position: relative;
    z-index: 1001;
}

/* Content styling */
.popup .popup-content {
    display: flex;
    gap: 20px;
}

.left, .right {
    width: 50%;
    text-align: center;
}

.left img {
    width: 80%;
    height: auto;
    border-radius: 50%;
}

.rating-number {
    font-size: 36px;
    font-weight: bold;
    background: linear-gradient(to right, #1D73A8, #FF0000);
    -webkit-background-clip: text;
    color: transparent;
    margin-bottom: 8px;
}

/* Rating box styling */
.rating-box {
    border: 1px solid rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    padding: 10px;
    text-align: center;
    background-color: #f8f8f8;
}

.title-line {
    width: 80%;
    height: 1px;
    background-color: #d1e9f9;
    margin: 8px auto;
}

/* Close button */
.close-popup {
    position: absolute;
    top: 10px;
    right: 10px;
    background-color: #f44336;
    color: white;
    border: none;
    padding: 5px 10px;
    cursor: pointer;
    border-radius: 3px;
}

.close-popup:hover {
    background-color: #d32f2f;
}
    </style>

    <div class="title">
        <h3>User list&nbsp<span class="las la-users"></span></h3>
    </div>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" SelectCommand="SELECT Patron.PatronId, [User].UserId, [User].UserName, [User].UserRole, [User].UserAddress, [User].UserEmail, [User].UserPhoneNumber, Patron.UserId AS Expr1 FROM Patron INNER JOIN [User] ON Patron.UserId = [User].UserId"></asp:SqlDataSource>
    <asp:GridView ID="GridView1" runat="server" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False"
        CssClass="user-list" CellPadding="4" DataSourceID="SqlDataSource1" DataKeyNames="UserId" ForeColor="#8390A2">
        <Columns>
            <asp:BoundField DataField="UserId" HeaderText="UserId" SortExpression="UserId" ReadOnly="True" />
            <asp:BoundField DataField="UserName" HeaderText="Name" SortExpression="UserName" />
            <asp:BoundField DataField="UserAddress" HeaderText="Address" SortExpression="UserAddress" />
            <asp:BoundField DataField="UserEmail" HeaderText="Email" SortExpression="UserEmail" />
            <asp:BoundField DataField="UserPhoneNumber" HeaderText="Phone Number" SortExpression="UserPhoneNumber" />

            <asp:TemplateField HeaderText="Action">
                <ItemTemplate>
                    <a href="javascript:void(0);" onclick="showUserPopup('<%# Eval("UserId") %>')">
                        <i class="las la-info-circle"></i>
                    </a>
                </ItemTemplate>

            </asp:TemplateField>
        </Columns>
        <HeaderStyle ForeColor="Black" />
    </asp:GridView>

    <div class="popup-overlay" style="display: none;">
    <div class="popup">
        <button onclick="closeUserPopup()" class="close-popup">X</button>
        <div class="popup-body">
            <div class="popup-content">
                <div class="left">
                    <img src="images/user-image.jpg" alt="User-photo">
                    <h4 id="popupUserId">User ID : </h4>
                    <h4 id="popupUserName">User Name : </h4>
                </div>
                <div class="right">
                    <div class="rating-number" id="popupTrustPoints"></div>
                    <div class="rating-box">
                        <div class="maintitle" id="popupTrustLevel"><b>Trust Level</b></div>
                        <div class="title-line"></div>
                        <div class="subtitle"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
    <script>
        function showUserPopup(userId) {
            fetch('UserTrustManagement.aspx/GetUserData', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ UserId: userId })  // Pass the userId as expected
            })
                .then(response => response.json())
                .then(result => {
                    const data = result.d;  // Access 'd' as it contains the actual data returned

                    if (data) {
                        document.getElementById("popupUserId").textContent = "User ID : " + data.userId;
                        document.getElementById("popupUserName").textContent = "User Name : " + data.name;
                        document.getElementById("popupTrustPoints").textContent = data.trustPoints;
                        document.getElementById("popupTrustLevel").textContent = "Trust Level " + data.trustLevel;
                        document.querySelector(".subtitle").textContent = data.borrowingMessage; // Display borrowing message

                        // Show the overlay and popup
                        document.querySelector(".popup-overlay").style.display = "flex";
                    } else {
                        console.error("No data found for the user ID:", userId);
                    }
                })
                .catch(error => console.error("Error fetching user data:", error));
        }

        function closeUserPopup() {
            document.querySelector(".popup-overlay").style.display = "none";
        }

    </script>
</asp:Content>
