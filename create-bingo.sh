#!/bin/bash

# Create the bingo game file
cat > itsmf-emerge-bingo.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ITSMF EMERGE Networking Bingo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            background-color: #f0f2f5;
            margin: 0;
            padding: 20px;
        }

        .container {
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            max-width: 800px;
            width: 100%;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        h1 {
            margin: 0;
            color: #1a1a1a;
        }

        .new-game-btn {
            padding: 10px 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.2s;
        }

        .new-game-btn:hover {
            background-color: #0056b3;
        }

        .bingo-board {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 10px;
            margin-bottom: 20px;
        }

        .bingo-cell {
            aspect-ratio: 1;
            padding: 10px;
            border: 2px solid #dee2e6;
            border-radius: 5px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 14px;
            background-color: white;
            position: relative;
        }

        .bingo-cell:hover {
            background-color: #f8f9fa;
        }

        .bingo-cell.selected {
            background-color: #007bff;
            color: white;
            border-color: #0056b3;
        }

        .bingo-cell img {
            max-width: 100%;
            max-height: 100%;
            object-fit: cover;
            border-radius: 3px;
            margin-top: 5px;
        }

        .camera-btn {
            position: absolute;
            bottom: 5px;
            right: 5px;
            background-color: rgba(0, 0, 0, 0.5);
            color: white;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 12px;
        }

        .camera-btn:hover {
            background-color: rgba(0, 0, 0, 0.7);
        }

        .bingo-message {
            text-align: center;
            padding: 15px;
            background-color: #d4edda;
            color: #155724;
            border-radius: 5px;
            display: none;
            font-weight: bold;
            margin-top: 20px;
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.8);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background-color: white;
            padding: 20px;
            border-radius: 10px;
            max-width: 90%;
            max-height: 90%;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        #camera-preview {
            max-width: 100%;
            margin-bottom: 10px;
        }

        .modal-buttons {
            display: flex;
            gap: 10px;
        }

        .capture-btn, .close-btn {
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .capture-btn {
            background-color: #28a745;
            color: white;
        }

        .close-btn {
            background-color: #dc3545;
            color: white;
        }

        @media (max-width: 600px) {
            .bingo-cell {
                font-size: 12px;
                padding: 5px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>ITSMF EMERGE Networking Bingo</h1>
            <button class="new-game-btn" onclick="resetBoard()">New Game</button>
        </div>
        <div class="bingo-board" id="bingoBoard"></div>
        <div class="bingo-message" id="bingoMessage">BINGO! 🎉</div>
    </div>

    <div class="modal" id="cameraModal">
        <div class="modal-content">
            <video id="camera-preview" autoplay playsinline></video>
            <canvas id="photo-canvas" style="display: none;"></canvas>
            <div class="modal-buttons">
                <button class="capture-btn" onclick="capturePhoto()">Take Photo</button>
                <button class="close-btn" onclick="closeCamera()">Close</button>
            </div>
        </div>
    </div>

    <script>
        const bingoItems = [
            "Exchanged business cards",
            "Met someone from your industry",
            "Awkward silence moment",
            "Learned about a new company",
            "Someone forgot their name",
            "Had a great laugh",
            "Made a potential connection",
            "Discussed current trends",
            "Got career advice",
            "Found common interests",
            "Mentioned the weather",
            "Connected on LinkedIn",
            "Shared a success story",
            "Got a coffee meeting",
            "Elevator pitch moment",
            "Met someone from abroad",
            "Discussed a recent event",
            "Shared industry insights",
            "Found mutual connection",
            "Learned new terminology",
            "Practiced active listening",
            "Shared contact info",
            "Made someone smile",
            "Got a referral",
            "Group conversation"
        ];

        let selectedCells = new Array(25).fill(false);
        let currentCellIndex = null;
        let stream = null;

        function shuffleArray(array) {
            const newArray = [...array];
            for (let i = newArray.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [newArray[i], newArray[j]] = [newArray[j], newArray[i]];
            }
            return newArray;
        }

        function createBoard() {
            const board = document.getElementById('bingoBoard');
            board.innerHTML = '';
            const shuffledItems = shuffleArray(bingoItems).slice(0, 25);
            
            shuffledItems.forEach((item, index) => {
                const cell = document.createElement('div');
                cell.className = 'bingo-cell';
                cell.innerHTML = `
                    <span>${item}</span>
                    <button class="camera-btn" onclick="openCamera(${index})">📷</button>
                `;
                cell.onclick = (e) => {
                    if (!e.target.classList.contains('camera-btn')) {
                        toggleCell(index, cell);
                    }
                };
                board.appendChild(cell);
            });
        }

        async function openCamera(index) {
            currentCellIndex = index;
            const modal = document.getElementById('cameraModal');
            const video = document.getElementById('camera-preview');
            
            try {
                stream = await navigator.mediaDevices.getUserMedia({ 
                    video: { facingMode: 'environment' }, 
                    audio: false 
                });
                video.srcObject = stream;
                modal.style.display = 'flex';
            } catch (err) {
                console.error('Error accessing camera:', err);
                alert('Unable to access camera. Please make sure you have granted camera permissions.');
            }
        }

        function closeCamera() {
            const modal = document.getElementById('cameraModal');
            const video = document.getElementById('camera-preview');
            
            if (stream) {
                stream.getTracks().forEach(track => track.stop());
                stream = null;
            }
            
            video.srcObject = null;
            modal.style.display = 'none';
            currentCellIndex = null;
        }

        function capturePhoto() {
            const video = document.getElementById('camera-preview');
            const canvas = document.getElementById('photo-canvas');
            const cell = document.getElementsByClassName('bingo-cell')[currentCellIndex];
            
            // Set canvas size to match video dimensions
            canvas.width = video.videoWidth;
            canvas.height = video.videoHeight;
            
            // Draw video frame to canvas
            const ctx = canvas.getContext('2d');
            ctx.drawImage(video, 0, 0);
            
            // Convert canvas to image
            const imageUrl = canvas.toDataURL('image/jpeg');
            
            // Add image to cell
            let img = cell.querySelector('img');
            if (!img) {
                img = document.createElement('img');
                cell.appendChild(img);
            }
            img.src = imageUrl;
            
            // Mark cell as selected
            toggleCell(currentCellIndex, cell);
            
            // Close camera
            closeCamera();
        }

        function toggleCell(index, cell) {
            selectedCells[index] = !selectedCells[index];
            cell.classList.toggle('selected');
            checkForBingo();
        }

        function checkForBingo() {
            const winningCombos = [
                // Rows
                [0,1,2,3,4], [5,6,7,8,9], [10,11,12,13,14], 
                [15,16,17,18,19], [20,21,22,23,24],
                // Columns
                [0,5,10,15,20], [1,6,11,16,21], [2,7,12,17,22],
                [3,8,13,18,23], [4,9,14,19,24],
                // Diagonals
                [0,6,12,18,24], [4,8,12,16,20]
            ];

            const hasBingo = winningCombos.some(combo => 
                combo.every(index => selectedCells[index])
            );

            document.getElementById('bingoMessage').style.display = 
                hasBingo ? 'block' : 'none';
        }

        function resetBoard() {
            selectedCells = new Array(25).fill(false);
            document.getElementById('bingoMessage').style.display = 'none';
            createBoard();
        }

        // Initialize the board when the page loads
        createBoard();
    </script>
</body>
</html>
EOF

# Make the file executable in a web browser
chmod 644 itsmf-emerge-bingo.html

echo "ITSMF EMERGE Networking Bingo game has been created as 'itsmf-emerge-bingo.html'"
echo "You can open it in your web browser to start playing!"
