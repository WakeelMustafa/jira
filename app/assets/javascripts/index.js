  var selectedProjectId = 0;
document.addEventListener("DOMContentLoaded", function() {
  document.getElementById("fetch-issues-button").disabled = true;

  function select(option) {
    var listItems = document.querySelectorAll('.list-group-item');
    listItems.forEach(function(item) {
      item.classList.remove("selected");
      item.style.backgroundColor = "transparent";
      let txt = item.textContent
      let newtxt = txt.replace("🟢", "").trim();
      item.textContent = newtxt;
    });
    option.classList.add("selected");
    option.innerHTML += "&nbsp;🟢";
    selectedProjectId = option.getAttribute('data-project-id');
    var projectId = option.getAttribute('data-project-id');

    let forms = option.closest(".container-question").querySelectorAll(".button_to");
    forms.forEach(function(form) {
      let form_href = form.action;
      form_href = form_href.replace(/\/\d+\//, `/${projectId}/`);
      form.action = form_href;
    });

    document.getElementById("fetch-issues-button").disabled = false;
  }

  var listItems = document.querySelectorAll('.list-group-item');
  listItems.forEach(function(item) {
    item.addEventListener('click', function() {
      select(this);
    });
  });
});

function showAlertAndDisableButton() {
  const alertDiv = document.createElement('div');
  alertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show', 'wait-alert');
  alertDiv.setAttribute('role', 'alert');

  alertDiv.innerHTML = `
    Fetching Jira issues, please wait...
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  `;

  document.body.insertBefore(alertDiv, document.body.firstChild);

  document.getElementById('fetch-issues-button').disabled = true;

  var projectId = selectedProjectId;

  $.ajax({
    type: 'POST',
    url: `/projects/${projectId}/fetch_issues`,
    data: { project_id: projectId },
    success: function(response) {
      const successAlertDiv = document.createElement('div');
      successAlertDiv.classList.add('alert', 'alert-success', 'alert-dismissible', 'fade', 'show');
      successAlertDiv.setAttribute('role', 'alert');

      successAlertDiv.textContent = 'Issues fetched successfully';

      document.body.insertBefore(successAlertDiv, document.body.firstChild);

      setTimeout(function() {
        successAlertDiv.style.display = 'none';
      }, 60000);

      document.getElementById('fetch-issues-button').disabled = false;

      alertDiv.style.display = 'none';

      window.location.href = `/edit_importing_project/${projectId}`;
    },
    error: function(xhr, status, error) {
      const errorAlertDiv = document.createElement('div');
      errorAlertDiv.classList.add('alert', 'alert-danger', 'alert-dismissible', 'fade', 'show');
      errorAlertDiv.setAttribute('role', 'alert');

      errorAlertDiv.textContent = 'Failed to fetch issues. Please try again later.';

      document.body.insertBefore(errorAlertDiv, document.body.firstChild);

      setTimeout(function() {
        errorAlertDiv.style.display = 'none';
      }, 60000);
    },
    complete: function() {
      document.getElementById('fetch-issues-button').disabled = false;
      
      alertDiv.style.display = 'none';
    }
  });
}
