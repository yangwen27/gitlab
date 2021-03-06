module CiStatusHelper
  def ci_status_path(ci_commit)
    project = ci_commit.project
    builds_namespace_project_commit_path(project.namespace, project, ci_commit.sha)
  end

  def ci_status_with_icon(status, target = nil)
    content = ci_icon_for_status(status) + '&nbsp;'.html_safe + ci_label_for_status(status)
    klass = "ci-status ci-#{status}"
    if target
      link_to content, target, class: klass
    else
      content_tag :span, content, class: klass
    end
  end

  def ci_label_for_status(status)
    if status == 'success'
      '通过'
    else
      ci_status_zh(status)
    end
  end

  def ci_icon_for_status(status)
    icon_name =
      case status
      when 'success'
        'check'
      when 'failed'
        'close'
      when 'running', 'pending'
        'clock-o'
      else
        'circle'
      end

    icon(icon_name + ' fw')
  end

  def ci_status_zh(status)
    case status
      when 'pending'
        '排队'
      when 'running'
        '运行'
      when 'success'
        '成功'
      when 'failed'
        '失败'
      when 'canceled'
        '取消'
      else
         '未知'
    end
  end

  def ci_stage_zh(stage)
    case stage
      when 'build'
        '构建'
      when 'deploy'
        '部署'
      when 'test'
        '测试'
      else
        stage.titleize
    end
  end

  def render_commit_status(commit, tooltip_placement: 'auto left')
    project = commit.project
    path = builds_namespace_project_commit_path(project.namespace, project, commit)
    render_status_with_link('提交', commit.status, path, tooltip_placement)
  end

  def render_pipeline_status(pipeline, tooltip_placement: 'auto left')
    project = pipeline.project
    path = namespace_project_pipeline_path(project.namespace, project, pipeline)
    render_status_with_link('管道', pipeline.status, path, tooltip_placement)
  end

  def no_runners_for_project?(project)
    project.runners.blank? &&
      Ci::Runner.shared.blank?
  end

  private

  def render_status_with_link(type, status, path, tooltip_placement)
    link_to ci_icon_for_status(status),
            path,
            class: "ci-status-link ci-status-icon-#{status.dasherize}",
            title: "#{type}：#{ci_label_for_status(status)}",
            data: { toggle: 'tooltip', placement: tooltip_placement }
  end
end
