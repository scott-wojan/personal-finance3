import axios from "axios";

axios.interceptors.response.use(
  function (response) {
    return response;
  },
  function (error) {
    if (401 === error.response.status) {
      window.location = "/signin";
    } else {
      return Promise.reject(error);
    }
  }
);
