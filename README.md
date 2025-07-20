# 📸 PicDrop

**PicDrop** is a Flutter app built in just 3 hours for a hackathon challenge. It is a work-in-progress and serves as a rapid prototype. Feel free to contribute, refine, and take it forward!

PicDrop automatically detects faces in your trip photos and organizes them into groups — one folder per person — using face detection technology. This makes it easy to share memories with friends and family after a trip, where each person gets their own folder of pictures featuring them.

### 🔍 Key Features
- Detect faces in trip photos using Google ML Kit
- Group photos based on detected faces
- Create folders for each detected person
- Auto-save cropped thumbnails of faces
- Show a visual preview of each person’s folder
- Designed to work offline

---

## ⚠️ Status: Incomplete Prototype

- ⛔ Face grouping logic might not be fully reliable
- ⛔ Thumbnails may not appear correctly due to path or file creation issues
- ⚙️ Functionality is limited and not production-ready
- ✅ Works as a basic proof-of-concept

---

## 🧠 Tech Stack

- **Flutter** (UI framework)
- **Google ML Kit** for face detection
- **Path Provider** for file system access
- **SharedPreferences** for local metadata storage
- **Image Picker** for photo input

---

## 📷 Screenshots

<table>
<tr>
  <td><img src="https://github.com/user-attachments/assets/235c4cec-20c6-4a2f-9e83-e510c4f6ccac" width="100%"/></td>
  <td><img src="https://github.com/user-attachments/assets/ccee294d-6e1c-4ba2-802a-d3817012c45e" width="100%"/></td>
</tr>
</table>

> 💡 Replace the above image paths with your actual screenshots in `assets/images/`.

---

## 💡 Improvements To Be Made

- Improve face detection confidence filtering
- Add manual face grouping
- Fix bugs with file saving and thumbnail creation
- Add support for editing, removing, or merging face folders
- UI enhancements and animations

---

## 🤝 Contributing

Pull requests are welcome. If you'd like to add features or fix bugs, feel free to fork the repo and submit a PR. Even better if you want to turn this into a real app!

---

## 🏁 Setup Instructions

```bash
git clone https://github.com/your-username/picdrop.git
cd picdrop
flutter pub get
flutter run
