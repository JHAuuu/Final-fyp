<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReturnBookManagement.aspx.cs" Inherits="fyp.ReturnBookManagement" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Return Book - Scan User ID</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html5-qrcode/2.3.8/html5-qrcode.min.js"></script>
    <script src="https://kit.fontawesome.com/a076d05399.js" crossorigin="anonymous"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap');
        /* General Reset */
        body, html {
            margin: 0;
            padding: 0;
            font-family: 'Poppins', sans-serif;
            background-color: #f7f8fa;
        }

        /* Header Section */
        header {
            background-color: #4CAF50;
            color: white;
            padding: 20px 0;
            text-align: center;
            font-size: 24px;
            font-weight: bold;
        }

            header h1 {
                margin: 0;
            }

        /* Main Content */
        .container {
            max-width: 800px;
            margin: 20px auto;
            background: white;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            border-radius: 12px;
            overflow: hidden;
            padding: 30px;
        }

        .content {
            text-align: center;
        }

        /* Status Bar */
        .status-bar {
            font-size: 16px;
            margin-bottom: 10px;
            padding: 10px;
            background-color: #eaf2ff;
            border-left: 4px solid #4CAF50;
            text-align: left;
            margin-bottom: 20px;
            border-radius: 5px;
        }

        /* Buttons */
        .buttons {
            margin-top: 30px;
        }

            .buttons button {
                font-size: 18px;
                padding: 12px 30px;
                margin: 15px;
                border: none;
                border-radius: 50px;
                cursor: pointer;
                transition: transform 0.2s ease, background-color 0.3s;
                width: 200px;
                display: inline-block;
                text-align: center;
            }

                .buttons button:hover {
                    transform: scale(1.05);
                }

        #start-scan-button {
            background-color: #4CAF50;
            color: white;
            font-size: 18px;
        }

            #start-scan-button i {
                margin-right: 10px;
            }

        #stop-scan-button {
            background-color: #f44336;
            color: white;
            font-size: 18px;
            display: none;
        }

        #start-scan-button, #stop-scan-button {
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /* Scanner Section */
        .scanner-container {
            display: none;
            margin: 20px auto;
            text-align: center;
        }

        #reader {
            width: 100%;
            max-width: 400px;
            height: 400px;
            margin: auto;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        /* Modal for password input */
        #passwordModal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
            padding-top: 60px;
            animation: fadeIn 0.3s ease;
        }

        #modalContent {
            background-color: #fff;
            margin: 5% auto;
            padding: 30px;
            border-radius: 10px;
            width: 300px;
            text-align: center;
        }

        .modal-close {
            color: #aaa;
            float: right;
            font-size: 30px;
            font-weight: bold;
        }

            .modal-close:hover, .modal-close:focus {
                color: black;
                text-decoration: none;
                cursor: pointer;
            }

        h3#modalUserName {
            font-size: 18px;
            margin-bottom: 20px;
        }

        .password-input {
            padding: 10px;
            font-size: 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid #ddd;
        }

        .submit-button {
            padding: 12px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
        }

            .submit-button:hover {
                background-color: #45a049;
            }

        /* Modal Close Animation */
        @keyframes fadeIn {
            from {
                opacity: 0;
            }

            to {
                opacity: 1;
            }
        }

        /* Footer */
        footer {
            margin-top: 30px;
            text-align: center;
            color: #777;
            font-size: 14px;
        }

            footer p {
                margin: 0;
            }
            .MessageBox{
                margin: 10px;
            }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header>
            <h1>Library Management System</h1>
        </header>
        <div class="container">
            <div class="content">
                <div class="status-bar" id="status">
                    Status: Click the button below to start or stop scanning your User ID.
               
                </div>
                <div class="buttons">
                    <button type="button" id="start-scan-button">
                        <i class="fas fa-camera"></i>Start Scanning
                   
                    </button>
                    <button type="button" id="stop-scan-button" style="display: none;">
                        <i class="fas fa-stop"></i>Stop Scanning
                   
                    </button>
                </div>
                <div class="scanner-container" id="scanner-container">
                    <div id="reader"></div>
                </div>
            </div>
        </div>
        <asp:HiddenField ID="hfUserName" runat="server" />
        <!-- Modal for password input -->
        <div id="passwordModal">
            <div id="modalContent">
                <span class="modal-close" id="closeModal">&times;</span>
                <h3 id="modalUserName" runat="server">Username : <asp:Label ID="lblUserName" runat="server" Text=""></asp:Label></h3>
                <label for="password">Password:</label>

                <asp:TextBox ID="submitPassword" runat="server" TextMode="Password" CssClass="password-input" required/>
                <asp:Label ID="MessageBox" runat="server" Text=""></asp:Label>
                <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClick="btnSubmit_Click" CssClass="submit-button" />
            </div>
        </div>

        <footer>
            <p>&copy; 2024 Library Management System. All Rights Reserved.</p>
        </footer>
    </form>

    <script>
        let qrScanner;
        let detectedUserID = "";
        let detectedUsername = "";

        function startScanner() {
            const scannerContainer = document.getElementById('scanner-container');
            scannerContainer.style.display = 'block';

            qrScanner = new Html5Qrcode("reader");

            qrScanner.start(
                { facingMode: "environment" }, // Use the back camera
                {
                    fps: 10,
                    qrbox: { width: 250, height: 250 } // Scanning box size
                },
                (decodedText) => {
                    // On successful scan
                    detectedUserID = decodedText;
                    console.log("Detected User ID:", detectedUserID);
                    verifyUserID(detectedUserID);
                    stopScanner(); // Stop after successful scan
                },
                (errorMessage) => {
                    // On error (optional)
                    console.warn(`QR Code Scan Error: ${errorMessage}`);
                }
            ).catch((err) => {
                console.error("QR Code Scanner Error:", err);
                document.getElementById('status').innerText = "Error starting scanner. Please try again.";
            });
        }

        function stopScanner() {
            if (qrScanner) {
                qrScanner.stop().then(() => {
                    const scannerContainer = document.getElementById('scanner-container');
                    scannerContainer.style.display = 'none';
                    resetScanButtons();
                }).catch((err) => {
                    console.error("Error stopping scanner:", err);
                });
            }
        }

        function verifyUserID(userId) {
            fetch("ReturnBookManagement.aspx/verifyUserId", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({
                    userId: userId
                })
            })
                .then(response => response.json())
                .then(responseJson => {
                    console.log(responseJson);
                    if (responseJson.d.status === "valid") {
                        detectedUsername = responseJson.d.username;
                        showPasswordModal(detectedUsername);
                    } else {
                        alert("Invalid QR Code. User not found.");
                        resetScanButtons();
                    }
                })
                .catch(error => {
                    // Handle network or other errors
                    console.error("Error verifying the User ID:", error);
                    alert("Error verifying the User ID.");
                    resetScanButtons();
                });
        }

        function resetScanButtons() {
            const startScanButton = document.getElementById('start-scan-button');
            const stopScanButton = document.getElementById('stop-scan-button');

            startScanButton.innerText = 'Start Scanning';  // Reset button text
            startScanButton.disabled = false;  // Enable the Start button
            stopScanButton.style.display = 'none';  // Hide the Stop button
        }

        function showPasswordModal(username) {
            document.getElementById('<%= hfUserName.ClientID %>').value = username;
            document.getElementById('<%= lblUserName.ClientID %>').innerText = username;
            document.getElementById('passwordModal').style.display = 'block';
        }

        document.getElementById('closeModal').addEventListener('click', function () {
            document.getElementById('passwordModal').style.display = 'none';
            document.getElementById('<%= submitPassword.ClientID %>').value = '';
        });

        document.getElementById('submitPassword').addEventListener('click', function () {
            const password = document.getElementById('password').value;
            if (password) {
                // Perform the password check or submit
                alert(`Password entered: ${password}`);
                window.location.href = `ProcessReturn.aspx?userid=${detectedUserID}`;
            } else {
                alert("Please enter a password.");
            }
        });

        document.getElementById('start-scan-button').addEventListener('click', function () {
            const startScanButton = document.getElementById('start-scan-button');
            const stopScanButton = document.getElementById('stop-scan-button');

            // Start scanning when the Start button is clicked
            startScanButton.disabled = true;  // Disable the Start button
            stopScanButton.style.display = 'inline-block';  // Show the Stop button

            startScanner();
        });

        document.getElementById('stop-scan-button').addEventListener('click', function () {
            stopScanner();  // Stop the scanner when the Stop button is clicked
        });

        
    </script>
</body>
</html>