try
    using TestFoldsDagger
    true
catch
    false
end || begin
    push!(LOAD_PATH, @__DIR__)
    using TestFoldsDagger
end
