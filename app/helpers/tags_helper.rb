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
        sub_branch[:text] = t.t_name
        sub_branch[:tags] = [t.id]
        build_subtree(sub_branch, t)
        branch[:nodes] << sub_branch
      end
    end
  end
end
