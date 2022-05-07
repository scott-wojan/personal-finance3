import $ from "jQuery";

$.fn.removeAttribute = function (name) {
  return this.each(function () {
    $.each(this.attributes, function () {
      this.ownerElement.removeAttribute(name);
    });

    $.each(this.children, function () {
      this.removeAttribute(name);
      $(this).removeAttribute(name);
    });
  });
};

$.fn.removeAllAttributes = function () {
  return this.each(function () {
    $.each(this.attributes, function () {
      this.ownerElement.removeAttributeNode(this);
    });

    $.each(this.children, function () {
      while (this.attributes.length > 0)
        this.removeAttribute(this.attributes[0].name);
      $(this).removeAllAttributes();
    });
  });
};

const baseUrl = "https://api.allorigins.win/get?url=";
let errorsUrl = baseUrl + encodeURIComponent("https://plaid.com/docs/errors/");
//
$.get(errorsUrl, function (response) {
  const html = response.contents;
  const links = $(html).find("div").find("section").not(":first").find("a");
  links.each((i, e) => {
    console.log($(e).attr("href"));
    getPage($(e).attr("href"));
  });
});

function getPage(link) {
  let url = baseUrl + encodeURIComponent("https://plaid.com" + link);

  const data = [];

  $.get(url, function (response) {
    const html = response.contents;

    const entries = $(html).find("div[class^='ErrorReference_errorReference']");
    let row = [];
    entries.each((i, e) => {
      const div = $(e);
      const subtitle = div.find("h5").text();
      const clientOrServerSide = div.find('span[role="note"]');
      const isServerSide = clientOrServerSide.first().text().includes("Server");
      const isClientSide = clientOrServerSide.last().text().includes("Client");
      const ul = div.find("div ul[class^='MDXComponents_ul']").first();
      const common_causes = ul.removeAttribute("class").prop("outerHTML");
      const troubleshooting_steps = [];

      div
        .find("div[class^='BaseInput-module_container'] label span p")
        .each((i, e) => {
          troubleshooting_steps.push($(e).html());
        });

      let troubleshootingUL = null;

      if (troubleshooting_steps.length > 0) {
        const listItems = troubleshooting_steps
          .map((step) => `<li>${step}</li>`)
          .join("");

        troubleshootingUL = `<ul>${listItems}</ul>`;
      }

      const code = div
        .find("div[class*='SideBySide_side']")
        .last()
        .find("pre div")
        .first();

      code.find("div").first().remove(); //remove http code
      code.find("span[class*='lineNumbers']").remove(); //remove line numbers
      //console.log(code.text())
      const jsonResponse = JSON.parse(code.text().replace(/\n|\r/g, ""));
      row = [
        jsonResponse.error_type,
        jsonResponse.error_code,
        subtitle,
        isServerSide,
        isClientSide,
        common_causes,
        troubleshootingUL,
        code.text(),
      ];
      data.push(row.join("*"));
    });
    $("#data").val(function (i, text) {
      return text + "\n" + data.join("\n");
    });
    //$('#data').val(data.join("\n"))
    //console.log(data.join("\n"));
  });
}
