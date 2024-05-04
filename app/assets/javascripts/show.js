document.addEventListener('DOMContentLoaded', function() {
  const addButtonModal = document.getElementById('add_mapping_modal');
  const fieldMappingsModal = document.getElementById('field_mappings_modal');

  function createSelect(name, options) {
    const col = document.createElement('div');
    col.className = 'col';

    const select = document.createElement('select');
    select.className = 'form-control';
    select.name = name;

    Object.entries(options).forEach(([value, text]) => {
      const option = document.createElement('option');
      option.value = value;
      option.textContent = text;
      select.appendChild(option);
    });

    col.appendChild(select);
    return col;
  }

  function addMappingRow() {
    const newRow = document.createElement('div');
    newRow.className = 'row field_mapping mb-2';

    const codegiantOptions = {
      'Title': 'Title',
      'Start Date': 'Start Date',
      'Due Date': 'Due Date',
      'Description': 'Description',
      'Story Points': 'Story Points',
      'Estimated Time': 'Estimated Time',
      'Actual Time': 'Actual Time'
    };
    const jiraOptions = {
      'summary': 'Summary',
      'description': 'Description',
      'jira_created_at': 'JIRA Created At',
      'due_date': 'Due Date',
      'estimated_time': 'Estimation Time',
      'actual_time': 'Original Time'
    };

    newRow.appendChild(createSelect('field_mapping[jira_field][]', jiraOptions));
    newRow.appendChild(createSelect('field_mapping[codegiant_field][]', codegiantOptions));

    fieldMappingsModal.appendChild(newRow);
  }

  addButtonModal.addEventListener('click', addMappingRow);
});

function showAlert() {
  const alertDiv = document.createElement('div');
  alertDiv.classList.add('alert', 'alert-info', 'alert-dismissible', 'fade', 'show', 'wait-alert');
  alertDiv.setAttribute('role', 'alert');

  alertDiv.innerHTML = `
    Fetching CodeGiant Users, please wait...
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
      <span aria-hidden="true">&times;</span>
    </button>
  `;

  document.body.insertBefore(alertDiv, document.body.firstChild);

  document.getElementById('fetch-codegiant-user-button').disabled = true;

  var projectId = document.getElementById('project_id_hidden_field').value;
    
  $.ajax({
    type: 'POST',
    url: `/fetch_codegiant_users`,
    data: { project_id: projectId },
    success: function(response) {
      const successAlertDiv = document.createElement('div');
      successAlertDiv.classList.add('alert', 'alert-success', 'alert-dismissible', 'fade', 'show');
      successAlertDiv.setAttribute('role', 'alert');

      successAlertDiv.textContent = 'CodeGiant users fetched and saved successfully.';

      document.body.insertBefore(successAlertDiv, document.body.firstChild);

      setTimeout(function() {
        successAlertDiv.style.display = 'none';
      }, 60000);

      document.getElementById('fetch-codegiant-user-button').disabled = false;

      alertDiv.style.display = 'none';

      window.location.href = `/codegiant_users/${projectId}`;
    },
    error: function(xhr, status, error) {
      const errorAlertDiv = document.createElement('div');
      errorAlertDiv.classList.add('alert', 'alert-danger', 'alert-dismissible', 'fade', 'show');
      errorAlertDiv.setAttribute('role', 'alert');
  
      errorAlertDiv.textContent = 'Failed to fetch CodeGiant Users. Please try again later.';
  
      document.body.insertBefore(errorAlertDiv, document.body.firstChild);
  
      setTimeout(function() {
        errorAlertDiv.style.display = 'none';
      }, 60000);
    },
    complete: function() {
      document.getElementById('fetch-codegiant-user-button').disabled = false;
      
      alertDiv.style.display = 'none';
    }
  });
}
