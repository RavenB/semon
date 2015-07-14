/*
 *
 *
 */
function createTreeview(treeSelector, treeData) {
  $(treeSelector).treeview({
    data: treeData,
    showBorder: false,
    showTags: true,
    levels: 1,
    selectedBackColor: '#d2d6de',
    selectedColor: '#333333',
    onNodeSelected: function(event, data) {
      tagEditListItem(treeSelector, data);
    }
  });
}

/*
 * gets template asynchronously
 *
 */
function tagEditListItem(treeSelector, node) {
  var tag_ancestry = getParentAncestry(treeSelector, node) + node.tags[0];

  $.ajax({
    url: '/tags/' + node.tags[0] + '/edit',
    data: {
      campaign_id: $('#tag_campaign_id').val(),
      current_tag_id: node.tags[0],
      ancestry: tag_ancestry
    },
    complete: function (data) {
      $(treeSelector).find('li[data-nodeid="' + node.nodeId + '"]').after(data.responseText);
      $('.node-added').slideDown('fast');
      $('.node-added #tag_t_name').focus();
      $('.node-added').click(function (e) {
        // bootstrap-treeview has special listener on list items what causes the form
        // submit to fail
        // fixed this with stopPropagation on newly added list items
        e.stopPropagation();
      });
    }
  });
}

function getParentAncestry(treeSelector, node) {
  var parentNode = $(treeSelector).treeview('getParent', node);
  var ancestry = '';

  if (parentNode.nodeId !== undefined) {
    ancestry = getParentAncestry(treeSelector, parentNode) + parentNode.tags[0] + '/';
  }

  return ancestry;
}

function showFlashMsg(html) {
  if($('#flash-msg').length) {
    var $flashMsg = $('#flash-msg');
    $flashMsg.html(html);
    $flashMsg.slideDown('fast');
    setTimeout(function hideFlashMsg() {
      $flashMsg.slideUp('fast');
      $flashMsg.find('button').click();
    }, 2000);
  }
}
