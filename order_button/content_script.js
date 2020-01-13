// Create user div element to hold current user for use in other scripts
userDiv = document.createElement("div");
userDiv.id = "current-user";
userDiv.hidden = true;
document.lastElementChild.append(userDiv);

// Get user from storage
chrome.storage.sync.get(['user'], function({user}) {
  // add user to hidden div
  userDiv.setAttribute("value", user);

  // Mount socket.js to handle connection and logic
  const script = document.createElement('script');
  script.setAttribute("type", "module");
  script.setAttribute("src", chrome.extension.getURL('socket.js'));
  const head = document.head || document.getElementsByTagName("head")[0] || document.documentElement;
  head.insertBefore(script, head.lastChild);
})

// Update userDiv and button when user changes
chrome.storage.onChanged.addListener(function({user: {oldValue, newValue}}) {
  userDiv.setAttribute("value", newValue);

  var cartButton = document.querySelector("#addToCart_feature_div,#addToCartDiv");

  if (cartButton) {
    cartButton.innerHTML = cartButton.innerHTML.replace(oldValue, newValue);
  }
})
