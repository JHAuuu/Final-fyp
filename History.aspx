<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="History.aspx.cs" Inherits="fyp.History" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    History
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="assets/css/history.css" />
      <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    
                        <div class="row history-link">
                            <div class="history-link"><a href="History.aspx">History</a></div>
                            <div class="history-link"><a href="LoanHistory.aspx">Loan History</a></div>
                        </div>
                        <div class="row">
                            <header>
                                <h2>Your History</h2>
                            </header>
                            <form runat="server" id="form1">
                                <asp:Button ID="btnClearAll" runat="server" Text="Clear All" CssClass="clear-btn" OnClick="btnClearAll_Click" />
                            </form>
                                
                        </div>
    <asp:Panel ID="pnlNoHistory" runat="server" Visible="false">
    <div class="empty-message">
        <p>No history found. Start exploring books!</p>
    </div>
</asp:Panel>
                        


                            <!--Body Content-->
                            <asp:Repeater runat="server" ID="rptHistory">
                                <HeaderTemplate>
                                    <div class="history-container">
                                </HeaderTemplate>
                                <ItemTemplate>
                                     <div class="history-item" id="<%# Eval("BookId")%>">
                                <div class="time"><%# Eval("HistoryDate")%></div>
                                <img src="<%# Eval("BookImage")%>" width="100" alt="Books" />
                                <div class="details">
                                    <div class="book-title"><%# Eval("BookTitle")%></div>
                                    <div class="description">
                                        <span>Author:</span> <%# Eval("Authors")%><br />
                                        <span>Category:</span> <%# Eval("Categories")%>
                                    </div>
                                </div>
                                <div class="actions">
                                    <i class="fas fa-trash-alt" onclick="deleteHistory(<%# Eval("BookId")%>)"></i>
                                </div>
                            </div>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </div>
                                </FooterTemplate>
                            </asp:Repeater>


                                                    
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">

                <script src="assets/js/jquery.min.js"></script>
            <script src="assets/js/jquery.dropotron.min.js"></script>
            <script src="assets/js/jquery.scrolly.min.js"></script>
            <script src="assets/js/jquery.scrollex.min.js"></script>
            <script src="assets/js/browser.min.js"></script>
            <script src="assets/js/breakpoints.min.js"></script>
            <script src="assets/js/util.js"></script>
     <script src="assets/js/sweetalert2/sweetalert2.min.js"></script>
    <script>
        function deleteHistory(bookId) {
            $.ajax({
                url: 'History.aspx/DeleteHistory', // Ensure the URL matches the WebMethod
                type: 'POST',
                data: JSON.stringify({ bookId: bookId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "SUCCESS") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Deleted',
                            confirmButtonText: 'OK',
                            confirmButtonColor: '#3498db'
                        }).then(() => {
                            // Remove the history item from the UI
                            document.getElementById(bookId).remove();
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response.d || 'An error occurred while deleting.',
                            confirmButtonText: 'Try Again',
                            confirmButtonColor: '#e67e22'
                        });
                    }
                },
                error: function () {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Failed to delete. Please try again.',
                        confirmButtonText: 'OK',
                        confirmButtonColor: '#e67e22'
                    });
                }
            });
        }
    </script>
</asp:Content>
