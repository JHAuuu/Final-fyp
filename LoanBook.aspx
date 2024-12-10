<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="LoanBook.aspx.cs" Inherits="fyp.LoanBook" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Loan Book
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/loanBook.css" />
    <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
<div>
    <header>
        <h1>ISBN Scanner</h1>
       
    </header>
    <p id="detected-isbn">Detected ISBN: <span id="isbn-output">None</span></p>

    <div id="scanner-container">
        <video id="video" autoplay playsinline></video>
    </div>
</div>
                <!--Body Content-->
                <div class="form-container">
                    <form action="#" runat="server">
                            <div class="form-submit">
                                <button type="submit" id="send-button"
                                    style="width:125px;height:50px;"
                                    onclick="loanBook(event)" disabled>Loan</button>
                            
                            </div>
                            <div class="form-submit">
                         
                                <asp:Button ID="btnRedirect" 
                                    style="background-color: gray;margin-top: 10px; font-size: 16px;" 
                                    runat="server" Text="Cancel" OnClick="btnRedirect_Click" />

                            </div>
                        

                    </form>
                </div>

</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
    <script src="assets/js/main.js"></script>
    <script src="assets/js/sweetalert2/sweetalert2.min.js"></script>
      <script src="https://cdnjs.cloudflare.com/ajax/libs/quagga/0.12.1/quagga.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script type="text/javascript">

        let detectedISBN = "";

        // Get today's date in YYYY-MM-DD format
        const today = new Date().toISOString().split("T")[0];
        // Set the 'min' attribute of the input

        // Initialize QuaggaJS to scan ISBN
        Quagga.init({
            inputStream: {
                name: "Live",
                type: "LiveStream",
                target: document.querySelector('#scanner-container'),
                constraints: {
                    facingMode: "environment",
                    width: 640,
                    height: 480
                }
            },
            decoder: {
                readers: ["ean_reader"] // EAN reader for ISBN barcodes
            }
        }, function (err) {
            if (err) {
                console.error("QuaggaJS initialization error:", err);
                
                return;
            }
            Quagga.start();
        });

        // Detect ISBN using QuaggaJS
        Quagga.onDetected(function (data) {
            detectedISBN = data.codeResult.code;
            document.getElementById('isbn-output').innerText = detectedISBN;
            document.getElementById('send-button').disabled = false;
            console.log("Detected ISBN:", detectedISBN);
        });



 


        function loanBook(event) {
            event.preventDefault();

            // AJAX to check trust level
            $.ajax({
                url: 'LoanBook.aspx/checkTrustLevel',
                type: 'POST',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "SUCCESS") {
                        $.ajax({
                            url: 'LoanBook.aspx/InsertLoan',
                            type: 'POST',
                            data: JSON.stringify({ISBN: detectedISBN }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                if (response.d === "SUCCESS") {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Added to your loan',
                                        text: 'Now you can have the book',
                                        confirmButtonText: 'OK'
                                    }).then((result) => {
                                        if (result.isConfirmed) {
                                            window.location.href = "LoanList.aspx";
                                        }
                                    });
                                } else {
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Loan Failed',
                                        text: response.d,
                                        confirmButtonText: 'OK'
                                    });
                                }
                            }
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Loan Failed',
                            text: response.d,
                            confirmButtonText: 'OK'
                        });
                    }
                }
            });
        }


    </script>
</asp:Content>
