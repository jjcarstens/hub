// import {Socket} from "phoenix"

// const script = document.createElement('script');
// script.setAttribute("type", "module");
// script.setAttribute("src", chrome.extension.getURL('socket.js'));
// const head = document.head || document.getElementsByTagName("head")[0] || document.documentElement;
// head.insertBefore(script, head.lastChild);

// chrome.runtime.onStartup.addListener(function() {

//   let socket = new Socket("/socket", {params: {}})

//   socket.connect()

//   // Now that you are connected, you can join channels with a topic:
//   // let channel = socket.channel("topic:subtopic", {})
//   // channel.join()
//   //   .receive("ok", resp => { console.log("Joined successfully", resp) })
//   //   .receive("error", resp => { console.log("Unable to join", resp) })

//   window.__socket = socket;
// });