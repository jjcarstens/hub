let users = document.getElementsByName("user");

// Get current user to display
chrome.storage.sync.get(['user'], function(result) {
  console.log('User currently is ' + result.user);
  document.querySelector("input[value=" + result.user).checked = true;
});

// add click events for changing user
for (let item of users) {
  item.onclick = changeUser;
}

function changeUser(e) {
  chrome.storage.sync.set({user: e.target.value }, function () {
    console.log("User changed to " + e.target.value);
  })
}

