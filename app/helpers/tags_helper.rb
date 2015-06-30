module TagsHelper
  def treeview_json(tags)
    tree = []

    tags.each do |t|
      if t.root?
        branch = {}
        branch[:text] = t.t_name
        branch[:tags] = [t.id]
        build_subtree(branch, t)
        tree << branch
      end
    end

    tree.to_json.html_safe
  end

  def build_subtree(branch, tag)
    if tag.children.present?
      branch[:nodes] = []

      tag.children.each do |t|
        sub_branch = {}
        sub_branch[:text] = add_icon_if_connected(t)
        sub_branch[:tags] = [t.id]
        build_subtree(sub_branch, t)
        branch[:nodes] << sub_branch
      end
    end
  end

  # returns tag name or tag name with icon, if there is a connection to the parent
  def add_icon_if_connected(t)
    if t.t_connection.present?
      "#{t.t_name} <i class='fa fa-lock margin-left-10'></i>".html_safe
    else
      t.t_name
    end
  end
end
