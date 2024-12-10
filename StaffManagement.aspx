<%@ Page Title="StaffManagement" MasterPageFile="~/Master/DashMasterPage.Master" Language="C#" AutoEventWireup="true" CodeBehind="StaffManagement.aspx.cs" Inherits="fyp.StaffManagement" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
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

        .title {
            display: flex;
            justify-content: space-between;
        }

        .add-staff-button {
            padding: 5px 92px;
            font-size: 13px;
            background-color: #8390A2;
            color: white;
            border: none;
            border-radius: 5px;
        }

            .add-staff-button:hover {
                background-color: #58606c;
                transition: 300ms;
            }

        .modal {
            display: none; /* Hidden by default */
            position: fixed;
            z-index: 1000;
            padding-top: 50px;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
        }

        .modal-content {
            background-color: #ffffff;
            margin: auto;
            padding: 30px;
            border-radius: 10px;
            width: 400px;
            box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.3);
            position: relative;
            animation: slide-down 0.4s ease;
        }

        @keyframes slide-down {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }

            to {
                transform: translateY(0);
                opacity: 1;
            }
        }


        /* Close button */
        .close {
            position: absolute;
            top: 15px;
            right: 20px;
            font-size: 24px;
            cursor: pointer;
            color: #666;
            transition: color 0.2s;
        }

            .close:hover {
                color: #333;
            }

        /* Input fields */
        .input-field {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
            font-size: 16px;
        }

            .input-field:focus {
                border-color: #007bff;
                outline: none;
                box-shadow: 0 0 5px rgba(0, 123, 255, 0.3);
            }

        /* Submit button */
        .button {
            background-color: #007bff;
            color: white;
            padding: 12px;
            margin-top: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
            transition: background-color 0.3s;
        }

            .button:hover {
                background-color: #0056b3;
            }
    </style>
    <div class="title">
        <h3>Library Staff list</h3>
        <asp:Button ID="btnAddStaff" runat="server" CssClass="add-staff-button" Text="Register Staff" OnClientClick="showAddStaffModal(); return false;" />

        <div id="addStaffModal" class="modal" style="display: none;">
            <div class="modal-content">
                <span class="close" onclick="hideAddStaffModal()">&times;</span>
                <h3 style="text-align: center; color: #333;">Register New Staff</h3>

                <asp:Label ID="lblErrorMessage" runat="server" ForeColor="Red" CssClass="error-message"></asp:Label>
                <asp:TextBox ID="txtUserName" runat="server" Placeholder="User Name" CssClass="input-field" /><br />
                <asp:TextBox ID="txtUserAddress" runat="server" Placeholder="User Address" CssClass="input-field" /><br />
                <asp:TextBox ID="txtUserEmail" runat="server" Placeholder="User Email" CssClass="input-field" /><br />
                <asp:TextBox ID="txtUserPhoneNumber" runat="server" Placeholder="User Phone Number" CssClass="input-field" /><br />
                <asp:TextBox ID="txtUserPassword" runat="server" Placeholder="User Password" TextMode="Password" CssClass="input-field" /><br />
                <br />

                <asp:Button ID="btnSubmitStaff" runat="server" Text="Submit" CssClass="button" UseSubmitBehavior="false" OnClientClick="validateAndSubmitStaff(); return false;" />
            </div>
        </div>
    </div>
    <asp:Label ID="MessageBox" runat="server" ForeColor="Red"></asp:Label>

    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" SelectCommand="SELECT [UserId], [UserName], [UserRole], [UserAddress], [UserEmail], [UserPhoneNumber] FROM [User] WHERE ([UserRole] = @UserRole)" DeleteCommand="DELETE FROM [User] WHERE [UserId] = @UserId" InsertCommand="INSERT INTO [User] ([UserId], [UserName], [UserRole], [UserAddress], [UserEmail], [UserPhoneNumber]) VALUES (@UserId, @UserName, @UserRole, @UserAddress, @UserEmail, @UserPhoneNumber)" UpdateCommand="UPDATE [User] SET [UserName] = @UserName, [UserAddress] = @UserAddress, [UserEmail] = @UserEmail, [UserPhoneNumber] = @UserPhoneNumber WHERE [UserId] = @UserId">
        <DeleteParameters>
            <asp:Parameter Name="UserId" Type="Int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="UserId" Type="Int32" />
            <asp:Parameter Name="UserName" Type="String" />
            <asp:Parameter Name="UserRole" Type="String" />
            <asp:Parameter Name="UserAddress" Type="String" />
            <asp:Parameter Name="UserEmail" Type="String" />
            <asp:Parameter Name="UserPhoneNumber" Type="String" />
        </InsertParameters>
        <SelectParameters>
            <asp:Parameter DefaultValue="Staff" Name="UserRole" Type="String" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="UserName" Type="String" />
            <asp:Parameter Name="UserAddress" Type="String" />
            <asp:Parameter Name="UserEmail" Type="String" />
            <asp:Parameter Name="UserPhoneNumber" Type="String" />
            <asp:Parameter Name="UserId" Type="Int32" />
        </UpdateParameters>
    </asp:SqlDataSource>

    <asp:GridView ID="GridView1" runat="server" OnRowEditing="GridView1_RowEditing"
        OnRowCancelingEdit="GridView1_RowCancelingEdit" OnRowUpdating="GridView1_RowUpdating"
        AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False"
        CssClass="user-list" CellPadding="4" DataSourceID="SqlDataSource1" DataKeyNames="UserId" ForeColor="#8390A2">
        <Columns>
            <asp:BoundField DataField="UserId" HeaderText="UserId" SortExpression="UserId" ReadOnly="True" />
            <asp:TemplateField HeaderText="Name">
                <ItemTemplate>
                    <asp:Label ID="lblUserName" runat="server" Text='<%# Eval("UserName") %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtUserName" runat="server" Text='<%# Bind("UserName") %>' CssClass="input-field" />
                    <asp:RequiredFieldValidator ID="rfvUserName" runat="server" ControlToValidate="txtUserName"
                        ErrorMessage="Name is required." CssClass="error-message" Display="Dynamic" ValidationGroup="UserUpdate" />
                    <asp:RegularExpressionValidator
                        ID="revUserName"
                        runat="server"
                        ControlToValidate="txtUserName"
                        ValidationExpression="^[a-zA-Z\s]{5,}$"
                        ErrorMessage="Name must be at least 5 characters and contain only letters and spaces."
                        CssClass="error-message"
                        Display="Dynamic"
                        ValidationGroup="UserUpdate" />
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="UserRole" HeaderText="UserRole" SortExpression="UserRole" ReadOnly="True" />
            <asp:TemplateField HeaderText="Address">
                <ItemTemplate>
                    <asp:Label ID="lblUserAddress" runat="server" Text='<%# Eval("UserAddress") %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtUserAddress" runat="server" Text='<%# Bind("UserAddress") %>' CssClass="input-field" />
                    <asp:RequiredFieldValidator ID="rfvUserAddress" runat="server" ControlToValidate="txtUserAddress"
                        ErrorMessage="Address is required." CssClass="error-message" Display="Dynamic" ValidationGroup="UserUpdate" />
                    <asp:RegularExpressionValidator
                        ID="revUserAddress"
                        runat="server"
                        ControlToValidate="txtUserAddress"
                        ValidationExpression="^[a-zA-Z0-9\s,\.#\-]{10,200}$"
                        ErrorMessage="Address must be between 10 and 200 characters and may only contain letters, numbers, spaces, commas, periods, '#', and hyphens."
                        CssClass="error-message"
                        Display="Dynamic"
                        ValidationGroup="UserUpdate" />
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="UserEmail">
                <ItemTemplate>
                    <asp:Label ID="lblUserEmail" runat="server" Text='<%# Eval("UserEmail") %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtUserEmail" runat="server" Text='<%# Bind("UserEmail") %>' CssClass="input-field" />
                    <asp:RequiredFieldValidator
                        ID="rfvUserEmail"
                        runat="server"
                        ControlToValidate="txtUserEmail"
                        ErrorMessage="Email is required."
                        CssClass="error-message"
                        Display="Dynamic"
                        ValidationGroup="UserUpdate" />
                    <asp:RegularExpressionValidator
                        ID="revUserEmail"
                        runat="server"
                        ControlToValidate="txtUserEmail"
                        ValidationExpression="^[^@\s]+@([^@\s]+\.)+[^@\s]+$"
                        ErrorMessage="Invalid email format."
                        CssClass="error-message"
                        Display="Dynamic"
                        ValidationGroup="UserUpdate" />
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Phone Number">
                <ItemTemplate>
                    <asp:Label ID="lblUserPhoneNumber" runat="server" Text='<%# Eval("UserPhoneNumber") %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtUserPhoneNumber" runat="server" Text='<%# Bind("UserPhoneNumber") %>' CssClass="input-field" />
                    <asp:RequiredFieldValidator ID="rfvUserPhoneNumber" runat="server" ControlToValidate="txtUserPhoneNumber"
                        ErrorMessage="Phone number is required." CssClass="error-message" Display="Dynamic" ValidationGroup="UserUpdate" />
                    <asp:RegularExpressionValidator 
    ID="revUserPhoneNumber" 
    runat="server" 
    ControlToValidate="txtUserPhoneNumber" 
    ValidationExpression="^01\d{8,9}$" 
    ErrorMessage="Phone number is in the wrong format." 
    CssClass="error-message" 
    Display="Dynamic" 
    ValidationGroup="UserUpdate" />
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Action">
                <ItemTemplate>
                    <asp:LinkButton ID="EditButton" runat="server" CommandName="Edit" CssClass="action-link" CausesValidation="false">
                    <i class="las la-user-edit"></i>
                </asp:LinkButton>
                    &nbsp;
                    <!-- Add space between buttons -->
                    <asp:LinkButton ID="DeleteButton" runat="server" CommandName="Delete" CssClass="action-link" OnClientClick="return confirm('Are you sure you want to delete this user?');">
                    <i class="las la-trash"></i>
                </asp:LinkButton>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:LinkButton ID="UpdateButton" runat="server" CommandName="Update" Text="Update" CssClass="button" CausesValidation="true" ValidationGroup="UserUpdate" />
                    <asp:LinkButton ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancel" CssClass="button" CausesValidation="false" />
                </EditItemTemplate>
            </asp:TemplateField>
        </Columns>
        <HeaderStyle ForeColor="Black" />
    </asp:GridView>


    <script>
        //register user button action
        function showAddStaffModal() {
            document.getElementById('addStaffModal').style.display = 'block';
        }

        function hideAddStaffModal() {
            document.getElementById('addStaffModal').style.display = 'none';
        }

        function validateAndSubmitStaff() {
            const userName = document.getElementById('<%= txtUserName.ClientID %>').value;
        const userAddress = document.getElementById('<%= txtUserAddress.ClientID %>').value;
        const userEmail = document.getElementById('<%= txtUserEmail.ClientID %>').value;
        const userPhoneNumber = document.getElementById('<%= txtUserPhoneNumber.ClientID %>').value;
        const userPassword = document.getElementById('<%= txtUserPassword.ClientID %>').value;

        // Validate All Fields Are Not Empty
        if (!userName || !userAddress || !userEmail || !userPhoneNumber || !userPassword) {
            document.getElementById('<%= lblErrorMessage.ClientID %>').innerText = "All fields are required and cannot be empty.";
            return;
        } else {
            // Validate Username
            if (userName.length < 3) {
                document.getElementById('<%= lblErrorMessage.ClientID %>').innerText = "Username must be at least 3 characters long.";
                return;
            }

            // Validate Email Format
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // Simple regex for email validation
            if (!emailPattern.test(userEmail)) {
                document.getElementById('<%= lblErrorMessage.ClientID %>').innerText = "Please enter a valid email address.";
                return;
            }

            // Validate Phone Number (Malaysian format)
            const phonePattern = /^(01[0-9]{8,9})$/; // Matches Malaysian phone numbers starting with 01 followed by 7 to 9 digits
            if (!phonePattern.test(userPhoneNumber)) {
                document.getElementById('<%= lblErrorMessage.ClientID %>').innerText = "Phone number must match Malaysian format (e.g., 0192485083 or 01155005083).";
                return;
            }
        }

        fetch('StaffManagement.aspx/CheckUserExistsAndInsertUser', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                userName: userName,
                userAddress: userAddress,
                userEmail: userEmail,
                userPhoneNumber: userPhoneNumber,
                userPassword: userPassword
            })
        })
            .then(response => response.json())
            .then(data => {
                if (data.d.success) {
                    // Display success message or reload the page
                    alert(data.d.message);
                    location.reload();
                } else {
                    // Display the error message in the modal
                    document.getElementById('<%= lblErrorMessage.ClientID %>').innerText = data.d.message;
                }
            })
                .catch(error => {
                    console.error('Error:', error);
                });
        }
</script>


</asp:Content>

