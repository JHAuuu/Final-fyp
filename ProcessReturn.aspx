<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProcessReturn.aspx.cs" Inherits="fyp.ProcessReturn" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Return Book</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/quagga/0.12.1/quagga.min.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap');
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #e0f7fa, #80deea); /* Gradient background */
            color: #333;
        }

        body, html {
            height: 100%; /* Full height for proper layout */
            display: flex;
            flex-direction: column;
        }

        header {
            background-color: #343a40;
            color: white;
            padding: 20px;
            text-align: center;
            font-size: 24px;
        }

        .btn-history {
            position: absolute;
            top: 20px;
            right: 20px;
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            font-size: 14px;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
            transition: background-color 0.3s, transform 0.2s;
            text-transform: uppercase;
        }

            .btn-history:hover {
                background-color: #0056b3; /* Darker blue on hover */
                transform: scale(1.05);
            }

            .btn-history:active {
                background-color: #003f7f; /* Darkest blue on click */
                transform: scale(1);
            }

        .container {
            flex: 1;
            max-width: 900px;
            margin: 180px auto 180px auto; /* Add margin-top to make space for the button */
            padding: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
            position: relative; /* For content layout */
        }

        .no-records {
            text-align: center;
            color: gray;
            font-size: 1.2em;
            margin: 20px 0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }

            table th, table td {
                border: 1px solid #ddd;
                padding: 12px;
                text-align: left;
            }

            table th {
                background-color: #f4f4f4;
            }

        .btn-scan {
            background-color: #4caf50; /* Green button */
            color: white;
            border: none;
            padding: 10px 16px;
            cursor: pointer;
            border-radius: 4px;
            font-size: 14px;
        }

            .btn-scan:hover {
                background-color: #388e3c; /* Darker green */
            }

        #scanner-container {
            text-align: center;
            margin-top: 20px;
        }

            #scanner-container video {
                width: 100%;
                max-width: 640px;
                border-radius: 8px;
            }

        #scan-result-container {
            margin-top: 20px; /* Consistent spacing */
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px; /* Space between text and button */
        }

        #scan-result {
            font-size: 18px;
            color: #333;
            margin-bottom: 10px;
        }

        .btn-stop {
            background-color: #dc3545; /* Red button for attention */
            color: white;
            padding: 10px 20px;
            font-size: 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-transform: uppercase;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
            transition: background-color 0.3s, transform 0.2s;
        }

            .btn-stop:hover {
                background-color: #b52a38; /* Darker red for hover */
                transform: scale(1.05);
            }

            .btn-stop:active {
                background-color: #8c202d; /* Even darker red on click */
                transform: scale(1);
            }

        footer {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 80px;
            background: linear-gradient(to right, #004d40, #00695c); /* Footer gradient */
            color: white;
            font-size: 14px;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .btn-history {
                top: 10px;
                right: 10px;
                font-size: 12px;
                padding: 8px 15px;
            }

            table th, table td {
                padding: 8px;
                font-size: 12px;
            }
        }

        .btn-logout {
            position: fixed; /* Fixed position */
            bottom: 80px; /* Distance from the bottom */
            right: 30px; /* Distance from the left */
            background-color: #dc3545; /* Red button */
            color: white;
            padding: 10px 15px;
            font-size: 14px;
            border: none;
            border-radius: 50px;
            cursor: pointer;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
            transition: background-color 0.3s, transform 0.2s;
            text-transform: uppercase;
            z-index: 1000; /* Ensure it's always on top */
        }

            .btn-logout:hover {
                background-color: #b52a38; /* Darker red on hover */
                transform: scale(1.05);
            }

            .btn-logout:active {
                background-color: #8c202d; /* Even darker red on click */
                transform: scale(1);
            }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <header>
            <h1>Library Management System - Return Book</h1>
            <asp:Button ID="btnViewHistory" runat="server" Text="View History" CssClass="btn-history" OnClick="btnViewHistory_Click" />
        </header>
        <div class="container">
            <div id="NoRecords" runat="server" visible="false" class="no-records">
                No active loans found. You don't have any books to return.
           
            </div>

            <asp:Repeater ID="Repeater1" runat="server" OnPreRender="Repeater1_PreRender">
                <HeaderTemplate>
                    <table>
                        <thead>
                            <tr>
                                <th>Book Title</th>
                                <th>ISBN</th>
                                <th>Loan Date</th>
                                <th>Return Date</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td><%# Eval("BookTitle") %></td>
                        <td><%# Eval("ISBN") %></td>
                        <td><%# Eval("StartDate", "{0:dd MMM yyyy}") %></td>
                        <td><%# Eval("EndDate", "{0:dd MMM yyyy}") %></td>
                        <td>
                            <button type="button" class="btn-scan" onclick="startScanning('<%# Eval("ISBN") %>')">Return</button>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                    </tbody>
                    </table>
               
                </FooterTemplate>
            </asp:Repeater>


        </div>

        <div id="scanner-container" style="display: none;background-color:darkgray;">
            <h2>Scan the book's ISBN</h2>
            <video id="video" autoplay playsinline></video>
            <div id="scan-result-container">
                <p id="scan-result">Detected ISBN: <span id="detected-isbn">None</span></p>
                <button type="button" class="btn-stop" onclick="stopScanning()">Stop Scanning</button>
            </div>
        </div>
        <asp:Button ID="btnLogout" runat="server" CssClass="btn-logout" OnClick="logOut_Click" Text="Log Out"></asp:Button>
        <footer>
            <p>&copy; 2024 Library Management System. All rights reserved.</p>
        </footer>
    </form>

    <script>
        let detectedISBN = "";
        let targetISBN = "";
        let isProcessing = false; // Flag to prevent multiple alerts
        let isScanning = false; // Flag to prevent multiple scanner instances

        // Start the scanner
        function startScanning(expectedISBN) {
            if (isScanning) {
                alert("Scanner is already running. Please stop it before starting a new scan.");
                return;
            }

            targetISBN = expectedISBN;
            detectedISBN = "";
            isProcessing = false; // Reset the flag
            isScanning = true; // Set the scanning flag
            document.getElementById('scanner-container').style.display = 'block';

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
                    readers: [
                        "ean_reader",          // EAN barcode reader
                        "code_128_reader",     // Code 128 (common for libraries)
                        "upc_reader"           // UPC barcodes (fallback for some books)
                    ],
                    multiple: false          // Only scan one barcode at a time
                },
                locate: true,                // Try to locate the barcode in the image
                locator: {
                    halfSample: true,        // Speeds up processing
                    patchSize: "medium",     // Area of image to scan
                    debug: {
                        drawBoundingBox: true,
                        showCanvas: true,
                        showPatches: true,
                        showFoundPatches: true,
                        showSkeleton: true
                    }
                }
            }, function (err) {
                if (err) {
                    console.error(err);
                    alert("Scanner initialization failed. Please try again.");
                    isScanning = false; // Reset scanning flag on error
                    return;
                }
                Quagga.start();
            });

            Quagga.onDetected(function (data) {
                if (isProcessing) return; // Prevent multiple detections
                detectedISBN = data.codeResult.code;
                document.getElementById('detected-isbn').innerText = detectedISBN;

                if (detectedISBN === targetISBN) {
                    isProcessing = true; // Set the flag to true
                    stopScanning();
                    processReturn();
                } else {
                    isProcessing = true; // Set the flag to true to avoid repeated alerts
                    alert("Scanned ISBN does not match. Please try again.");
                    setTimeout(() => isProcessing = false, 2000); // Reset the flag after 2 seconds
                }
            });
        }

        // Stop the scanner
        function stopScanning() {
            if (isScanning) {
                Quagga.stop(); // Properly stop the scanner
                isScanning = false; // Reset the scanning flag
                document.getElementById('scanner-container').style.display = 'none';
            }
        }

        // Process the return
        function processReturn() {
            $.ajax({
                url: 'ProcessReturn.aspx/HandleReturnProcess',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ isbn: detectedISBN }),
                success: function (response) {
                    alert(response.d);
                    window.location.reload();
                },
                error: function () {
                    alert("Error processing the return. Please try again.");
                }
            });
        }

    </script>
</body>
</html>
