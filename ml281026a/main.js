const { app, BrowserWindow } = require('electron')
  
let win
  
function createWindow () {
    // Create the browser window.
    win = new BrowserWindow({ width: 640, height: 480, useContentSize: true })
    win.loadFile(__dirname + '/index.html')
//    win.webContents.openDevTools();

    win.on('closed', () => {
      win = null
    })
}
  
app.on('ready', createWindow)
  
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
      app.quit()
    }
})
  
app.on('activate', () => {
    if (win === null) {
      createWindow()
    }
})