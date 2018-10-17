-- CharacterWindow is what pathofexile.com calls its character API.
--
-- This class is responsible for fetching and returning characters available
--   through the character-window URLs

JSON = require 'JSON'

CharacterWindow = common.NewClass("CharacterWindow", function(self)
end)

function PoeCurl(url, callback, cookies)
	ConPrintf("Downloading page at: %s", url)
	local curl = require("lcurl.safe")
	local page = ""
	local easy = curl.easy()
	easy:setopt_url(url)
	easy:setopt(curl.OPT_ACCEPT_ENCODING, "")
	if cookies then
		easy:setopt(curl.OPT_COOKIE, cookies)
	end
	if proxyURL then
		easy:setopt(curl.OPT_PROXY, proxyURL)
	end
	easy:setopt_writefunction(function(data)
		page = page..data
		return true
	end)
	local _, error = easy:perform()
	local code = easy:getinfo(curl.INFO_RESPONSE_CODE)
	easy:close()
	local errMsg
	if error then
		errMsg = error:msg()
	elseif code ~= 200 then
		errMsg = "Response code: "..code
	elseif #page == 0 then
		errMsg = "No data returned"
	end
	ConPrintf("Download complete. Status: %s", errMsg or "OK")
	if errMsg then
		return nil, errMsg
	else
		return page
	end
end

function CharacterWindow:getCharacterList(account_name)
	page, errMsg = PoeCurl("https://www.pathofexile.com/character-window/get-characters?accountName=" .. account_name)
	if errMsg then
		print(errMsg)
		exit()
	end
	return JSON:decode(page)
end


