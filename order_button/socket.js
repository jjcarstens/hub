"use strict";
import {Socket} from './phoenix.js';

(() => {

  const state = {
    cartButton: document.querySelector("#addToCart_feature_div,#addToCartDiv"),
    channel: null,
    user: document.getElementById("current-user").getAttribute("value"),
    socket: new Socket("wss://10.0.1.7:4081/socket", {params: {}}),
    thumbnail: null,
    title: null,
    price: null,
    orderStatus: null
  }

  /**
   * Functions
  **/
  function createOrderRequestButton(cartButton) {
    let newButtonHTML = `
    <div class="order-button-stack">
    <span id="create-order-request-button" class="order-button a-spacing-small">
      <span id="order-button-inner" class="order-button-inner">
        <center><div class="loader"></div></center>
      </span>
    </span>
    </div>
    `

    cartButton.innerHTML = newButtonHTML;
    cartButton.onclick = createOrderRequest;
  }

  function createOrderRequest(e) {
    if (state.orderStatus === "new") {
      state.channel.push("create_order", {link: window.location.href, price: state.price, thumbnail_url: state.thumbnail, title: state.title})
        .receive("ok", updateOrderButton)
        .receive("error", updateOrderButton)
    } else {
      alert(`This item was already ${state.orderStatus}.\n\nTalk to mom or dad for more info`);
    }
  }

  function removeUnwantedButtons() {
    let buyNow = document.getElementById("buyNow_feature_div");
    
    if (buyNow) {
      buyNow.parentNode.removeChild(buyNow);
    }
  }

  function updateOrderButton({order_status, msg}) {
    var innerText;
    switch(order_status) {
      case "new":
        innerText = `Request Order for [${state.user}]`
        break;
      case "created":
      case "requested":
      case "approved":
        innerText = `Order ${order_status} for [${state.user}]`
        break;
      case "denied":
        innerText = `Order denied for [${state.user}]`;
        break;
      case "error":
        innerText = msg
    }

    state.orderStatus = order_status;

    document.getElementById("create-order-request-button").classList.add(`order-button-${order_status}`);
    document.getElementById("order-button-inner").innerHTML = `<span id="create-order-request-text" class="order-button-text" aria-hidden="true">${innerText}</span>`;
  }

  /**
   * Logic
  **/

  if (state.cartButton) {
    state.thumbnail = document.querySelector(".image.itemNo0.selected img").getAttribute("src"),
    state.title = document.getElementById("productTitle").textContent.trim(),
    state.price = document.querySelector("[data-asin-price]").getAttribute("data-asin-price"),
    
    createOrderRequestButton(state.cartButton);
    removeUnwantedButtons();

    state.socket.connect();

    state.channel = state.socket.channel("orders:" + state.user, {link: window.location.href})
    state.channel.join()
      .receive("ok", updateOrderButton)
      .receive("error", updateOrderButton)
  } else {
    state.socket.connect();
    state.channel = state.socket.channel("orders:" + state.user)

    state.channel.join()
    .receive("ok", resp => {console.log("HOWDY!")})
    .receive("error", resp => {console.log(resp)})
  }

  // Support opening links from ATM
  state.channel.on("open", payload => {
    console.log("opening...")
    window.open(payload.link)
  })
})();