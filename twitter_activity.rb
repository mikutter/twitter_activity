# -*- coding: utf-8 -*-

Plugin.create(:twitter_activity) do
  BOOT_TIME = Time.new.freeze

  defactivity :follow, _("フォロー")
  defactivity :list_member_added, _("リストに追加")
  defactivity :list_member_removed, _("リストから削除")
  defactivity :dm, _("ダイレクトメッセージ")

  on_list_member_added do |service, user, list, source_user|
    title = _("@%{user}が%{list}に追加されました") % {
      user: user[:idname],
      list: list[:full_name] }
    desc_by_user = {
      description: list[:description],
      user: list.user[:idname] }
    activity(:list_member_added, title,
             description:("#{title}\n" +
                          _("%{description} (by @%{user})") % desc_by_user + "\n" +
                          "https://twitter.com/#{list.user[:idname]}/#{list[:slug]}"),
             icon: user.icon,
             related: user.me? || source_user.me?,
             service: service,
             children: [user, list, list.user])
  end

  on_list_member_removed do |service, user, list, source_user|
    title = _("@%{user}が%{list}から削除されました") % {
      user: user[:idname],
      list: list[:full_name] }
    desc_by_user = {
      description: list[:description],
      user: list.user[:idname] }
    activity(:list_member_removed, title,
             description:("#{title}\n"+
                          _("%{description} (by @%{user})") % desc_by_user + "\n" +
                          "https://twitter.com/#{list.user[:idname]}/#{list[:slug]}"),
             icon: user.icon,
             related: user.me? || source_user.me?,
             service: service,
             children: [user, list, list.user])
  end

  on_follow do |by, to|
    by_user_to_user = {
      followee: by[:idname],
      follower: to[:idname] }
    activity(:follow, _("@%{followee} が @%{follower} をﾌｮﾛｰしました") % by_user_to_user,
             related: by.me? || to.me?,
             icon: (to.me? ? by : to).icon,
             children: [by, to])
  end

  on_direct_messages do |service, dms|
    dms.each{ |dm|
      date = dm[:created]
      if date > BOOT_TIME
        activity(:dm, dm[:text],
                 description:
                   [ _('差出人: @%{sender}') % {sender: dm[:sender].idname},
                     _('宛先: @%{recipient}') % {recipient: dm[:recipient].idname},
                     '',
                     dm[:text]
                   ].join("\n"),
                 icon: dm[:sender].icon,
                 service: service,
                 date: date,
                 children: [dm.recipient, dm.sender, dm]) end }
  end
end
