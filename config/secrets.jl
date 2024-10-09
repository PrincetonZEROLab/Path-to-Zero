try
  Genie.Util.isprecompiling() || Genie.Secrets.secret_token!("ecba38d7a40167caf764cc501e44505d44d9c2ac05cbc05f8bc021359f410847")
catch ex
  @error "Failed to generate secrets file: $ex"
end
