<%@ Page Title="BookManagement" MasterPageFile="~/Master/DashMasterPage.Master" Language="C#" AutoEventWireup="true" CodeBehind="BookManagement.aspx.cs" Inherits="fyp.BookManagement" EnableViewState="true" EnableEventValidation="true" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField ID="hfModalState" runat="server" Value="false" />
    <asp:ScriptManager runat="server" EnablePageMethods="true" />
    <link rel="stylesheet" href="assets/css/BookManagement.css?v=1.0">
    <asp:SqlDataSource ID="SqlDataSourceAuthor" runat="server"
        ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
        SelectCommand="SELECT AuthorId, AuthorName FROM Author"></asp:SqlDataSource>
    <div class="upper">
        <div class="searchbar">
            <asp:TextBox ID="searchBar" runat="server" CssClass="search-input" placeholder="Search for a book..."></asp:TextBox>
            <asp:Button ID="btnSearch" runat="server" CssClass="search-btn" Text="Search" OnClick="btnSearch_Click" CausesValidation="False" />
        </div>
        <div class="buttons">
            <asp:Button ID="btnDraft" runat="server" CssClass="draft-Book-button" Text="Draft Book" OnClientClick="showDraftModal(); return false;"/>
            <div id="draftBookModal" class="modal" style="display: none;">
    <div class="modal-content" style="width:75%;">
        <span class="close" onclick="hideDraftModal()">&times;</span>
        <h3 style="text-align: center; color: #333;">Draft Books</h3>

        <asp:GridView ID="GridViewDraftBooks" runat="server" AutoGenerateColumns="False" CssClass="draft-grid" OnRowCommand="GridViewDraftBooks_RowCommand">
            <Columns>
                <asp:BoundField DataField="BookTitle" HeaderText="Book Title" />
                <asp:TemplateField HeaderText="Book Image">
                    <ItemTemplate>
                        <asp:Image ID="imgBookCover" runat="server" 
                            ImageUrl='<%# Eval("BookImage") != DBNull.Value ? "data:image/png;base64," + Convert.ToBase64String((byte[])Eval("BookImage")) : "~/images/defaultBookCover.png" %>' 
                            AlternateText="No Image Available" Width="100px" Height="150px" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:Button ID="btnRestoreBook" runat="server" Text="Restore" CommandName="RestoreBook" CommandArgument='<%# Eval("BookId") %>' CssClass="restore-button" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</div>
            <asp:Button ID="btnAddBook" runat="server" CssClass="add-Book-button" Text="Add Book" OnClientClick="showAddBookModal(); return false;" />

            <div id="addBookModal" class="modal" style="display: none;">
                <div class="modal-content">
                    <span class="close" onclick="hideAddBookModal()">&times;</span>
                    <h3 style="text-align: center; color: #333;">Add New Book</h3>

                    <asp:Label ID="lblErrorMessage" runat="server" ForeColor="Red" CssClass="error-message"></asp:Label>

                    <!-- Book Title -->
                    <asp:Label ID="lblBookTitle" runat="server" Text="Book Title" CssClass="book-title"></asp:Label>
                    <asp:RequiredFieldValidator ID="rfvBookTitle" runat="server" ControlToValidate="txtBookTitle" ErrorMessage="*Book Title is required." ForeColor="Red" ValidationGroup="submitValidationGroup" />
                    <br />
                    <asp:TextBox ID="txtBookTitle" runat="server" Placeholder="Book Title" CssClass="input-field" MaxLength="100" /><br />
                    <br />


                    <!-- Book Description -->
                    <asp:Label ID="LblBDesc" runat="server" Text="Book Description" CssClass="input-label" />
                    <asp:RequiredFieldValidator ID="rfvBookDesc" runat="server" ControlToValidate="txtBookDesc" ErrorMessage="*Book Description is required." ForeColor="Red" ValidationGroup="submitValidationGroup" />
                    <br />
                    <asp:TextBox ID="txtBookDesc" runat="server" Placeholder="Book Description" CssClass="input-field" TextMode="MultiLine" Rows="4" MinLength="10" MaxLength="500" /><br />


                    <!-- Book Series -->
                    <asp:Label ID="lblBookSeries" runat="server" Text="Book Series" CssClass="input-label" />
                    <asp:RequiredFieldValidator ID="rfvBookSeries" runat="server" ControlToValidate="txtBookSeries" ErrorMessage="*Book Series is required." ForeColor="Red" ValidationGroup="submitValidationGroup" />
                    <br />
                    <asp:TextBox ID="txtBookSeries" runat="server" Placeholder="Book Series" CssClass="input-field" MaxLength="20" /><br />

                    <!-- Categories -->
                    <asp:Label ID="lblCategories" runat="server" Text="Categories" CssClass="input-label" />
                    <asp:CheckBoxList ID="cblCategoryIds" runat="server" CssClass="check-field"
                        DataSourceID="SqlDataSourceCategory" DataTextField="CategoryName" DataValueField="CategoryId" />

                    <asp:SqlDataSource ID="SqlDataSourceCategory" runat="server"
                        ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
                        SelectCommand="SELECT CategoryId, CategoryName FROM Category"></asp:SqlDataSource>

                    <!-- Add New Category -->
                    <asp:Label ID="lblNewCategory" runat="server" Text="Or Enter New Category" CssClass="input-label" />
                    <asp:TextBox ID="txtNewCategory" runat="server" Placeholder="New Category Name" CssClass="input-field" MaxLength="50" />
                    <asp:Button ID="btnAddCategory" runat="server" Text="Add New Category" OnClick="btnAddCategory_Click" ValidationGroup="AddCategoryValidationGroup" />
                    <asp:RequiredFieldValidator ID="rfvNewCategory" runat="server" ControlToValidate="txtNewCategory"
                        ErrorMessage="New Category Name is required." ForeColor="Red" ValidationGroup="AddCategoryValidationGroup" />
                    <br />

                    <!-- Author Selection -->
                    <asp:Label ID="lblAuthor" runat="server" Text="Select Author" CssClass="input-label" />
                    <asp:CheckBoxList ID="cblAuthors" runat="server" CssClass="check-field"
                        DataSourceID="SqlDataSourceAuthor" DataTextField="AuthorName" DataValueField="AuthorId" />

                    <!-- New Author Name Input -->
                    <asp:Label ID="lblNewAuthor" runat="server" Text="Or Enter New Author" CssClass="input-label" />
                    <asp:Button ID="btnAddAuthor" runat="server" Text="Add New Author" OnClick="btnAddAuthor_Click" ValidationGroup="AddAuthorValidationGroup" />
                    <asp:TextBox ID="txtNewAuthor" runat="server" Placeholder="New Author Name" CssClass="input-field" MaxLength="50" />
                    <asp:RequiredFieldValidator ID="rfvNewAuthor" runat="server" ControlToValidate="txtNewAuthor" ErrorMessage="New Author Name is required." ForeColor="Red" ValidationGroup="AddAuthorValidationGroup" />
                    <br />
                    <!-- Book Cover Image -->
                    <asp:Label ID="lblBookImage" runat="server" Text="Book Cover Image" CssClass="input-label" />
                    <asp:FileUpload ID="fileUploadBookImage" runat="server" CssClass="input-field" /><br />
                    <asp:RequiredFieldValidator ID="rfvBookImage" runat="server" ControlToValidate="fileUploadBookImage" ErrorMessage="Book Image is required." ForeColor="Red" ValidationGroup="submitValidationGroup" />
                    <br />
                    <asp:RegularExpressionValidator ID="revBookImage" runat="server" ControlToValidate="fileUploadBookImage" ErrorMessage="Only image files (jpg, jpeg, png, gif) are allowed." ForeColor="Red" ValidationExpression="^.*\.(jpg|jpeg|png|gif)$" ValidationGroup="submitValidationGroup" />
                    <br />

                    <!-- Submit Button -->
                    <asp:Button ID="btnSubmitBook" runat="server" Text="Submit" CssClass="button" OnClick="btnSubmitBook_Click" ValidationGroup="submitValidationGroup" OnClientClick="return validateForm();" />
                </div>
            </div>

        </div>
    </div>

    <asp:Label ID="MessageBox" runat="server" ForeColor="Red"></asp:Label>

    <asp:SqlDataSource
        ID="SqlDataSource1"
        runat="server"
        ConnectionString="<%$ ConnectionStrings:ConnectionString %>"
        SelectCommand="SELECT BookId, BookTitle, BookDesc, BookSeries, BookImage FROM Book WHERE IsDeleted = 0"></asp:SqlDataSource>
    <div class="product-container">
        <asp:Repeater ID="BooksRepeater" runat="server" DataSourceID="SqlDataSource1">
            <ItemTemplate>
                <div class="card">
                    <div class="content">
                        <div class="title"><%# Eval("BookTitle") %></div>
                        <div class="image">
                            <asp:Image ID="imageBook" runat="server"
                                ImageUrl='<%# Eval("BookImage") != DBNull.Value ? "data:image/png;base64," + Convert.ToBase64String((byte[])Eval("BookImage")) : "images/defaultCoverBook.png" %>'
                                AlternateText='<%# Eval("BookTitle") %>' />
                        </div>
                        <b>ID: <%# Eval("BookId") %></b>
                        <asp:Label ID="lblBookDesc" runat="server" Text='<%# Eval("BookDesc") %>' CssClass="text"></asp:Label>
                    </div>
                    <%--<asp:LinkButton ID="btnView" runat="server" Text="View Book" CssClass="view-book"  
                            CommandArgument='<%# Eval("BookId") %>' OnCommand="btnView_Command" />--%>
                    <asp:Button ID="btnView" runat="server" Text="View Book" CssClass="view-book"
                        CommandArgument='<%# Eval("BookId") %>' OnClick="btnView_Click" CausesValidation="false" />
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <script>
        window.onload = function () {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('message') === 'deleted') {
                alert("Book deleted successfully.");
            }
        };

        //register user button action
        function showAddBookModal() {
            document.getElementById('addBookModal').style.display = 'block';
        }

        function validateCheckboxList(sender, args) {
            var checkBoxList = document.getElementById('<%= cblCategoryIds.ClientID %>');
            var checkboxes = checkBoxList.getElementsByTagName("input");
            args.IsValid = Array.from(checkboxes).some(checkbox => checkbox.checked);
        }

        window.onload = function () {
            var modalState = document.getElementById('<%= hfModalState.ClientID %>').value;
            if (modalState === 'true') {
                document.getElementById('addBookModal').style.display = 'block';
            }
        };

        function hideAddBookModal() {
            // Hide the modal
            document.getElementById("addBookModal").style.display = "none";

            // Reset the modal state
            document.getElementById('<%= hfModalState.ClientID %>').value = 'false';

            // Clear all input fields in the modal except the submit button
            const modal = document.getElementById("addBookModal");
            const inputs = modal.querySelectorAll("input, textarea, select");

            inputs.forEach(input => {
                if (input.type === "checkbox" || input.type === "radio") {
                    input.checked = false; // Uncheck checkboxes and radio buttons
                } else if (input.tagName.toLowerCase() === "select") {
                    input.selectedIndex = 0; // Reset dropdowns
                } else if (input.type !== "submit" && input.type !== "button") {
                    input.value = ""; // Clear text, file, and other input types
                }
            });

            // Clear validation messages
            const errorMessages = modal.querySelectorAll(".error-message, .validation-summary-errors");
            errorMessages.forEach(error => (error.innerText = ""));
        }

        function validateForm() {
            // Trigger all ASP.NET validations first (for required fields, etc.)
            var isValid = Page_ClientValidate('submitValidationGroup');  // Validate all fields in the 'submitValidationGroup'

            if (!isValid) {
                return false;  // If any validation fails, stop the form from submitting
            }

            // Run the custom category validation after ASP.NET validations
            return validateCheckboxesSelection();  // If the category validation fails, prevent submission
        }

        function validateCheckboxesSelection() {
            // Get the category and author CheckBoxLists
            var categoryCheckboxes = document.getElementById('<%= cblCategoryIds.ClientID %>').getElementsByTagName('input');
            var authorCheckboxes = document.getElementById('<%= cblAuthors.ClientID %>').getElementsByTagName('input');

            var isCategoryChecked = false;
            var isAuthorChecked = false;

            // Loop through each checkbox in the category CheckBoxList
            for (var i = 0; i < categoryCheckboxes.length; i++) {
                if (categoryCheckboxes[i].type === 'checkbox' && categoryCheckboxes[i].checked) {
                    isCategoryChecked = true;
                    break;
                }
            }

            // Loop through each checkbox in the author CheckBoxList
            for (var j = 0; j < authorCheckboxes.length; j++) {
                if (authorCheckboxes[j].type === 'checkbox' && authorCheckboxes[j].checked) {
                    isAuthorChecked = true;
                    break;
                }
            }

            // If no category checkbox is selected, show an error message
            if (!isCategoryChecked) {
                alert("Please select at least one category.");
                return false;
            }

            // If no author checkbox is selected, show an error message
            if (!isAuthorChecked) {
                alert("Please select at least one author.");
                return false;
            }

            // If at least one checkbox is selected in both lists, allow form submission
            return true;
        }

        function showDraftModal() {
            document.getElementById('draftBookModal').style.display = 'block';
        }

        function hideDraftModal() {
            document.getElementById('draftBookModal').style.display = 'none';
        }
    </script>
</asp:Content>
