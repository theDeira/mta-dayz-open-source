function getGangSlots(gangname)
  local account = getAccount(getGangLeader(gangname))
  if account then
    return getAccountData(account, "gangslots") or 0
  else
    return 12
  end
end
function checkPlayerGroupDetails()
  gangtable = {}
  local gangtablename = getGangList()
  for i, group in pairs(gangtablename) do
    local gangtablemembers = #getGangMembers(group.gang_name)
    local groupleader = getGangLeader(group.gang_name)
    local gangvip = getGangSlots(group.gang_name)
    table.insert(gangtable, {
      group.gang_name,
      groupleader,
      gangtablemembers,
      gangvip
    })
  end
  setElementData(getRootElement(), "ganglist", gangtable)
end
setTimer(checkPlayerGroupDetails, 120000, 0)
checkPlayerGroupDetails()
playerTeam = createTeam("Player")
function updateGangTable()
  setElementData(getRootElement(), "ganglist", gangtable)
  setPlayerTeam(source, playerTeam)
end
addEventHandler("onPlayerJoin", getRootElement(), updateGangTable)
function groupChat(message, messageType)
  cancelEvent()
  if messageType == 2 then
    if getElementData(source, "gang") == "None" then
      return
    end
    if not doesGangExists(getElementData(source, "gang")) then
      return
    end
    for i, player in ipairs(getPlayersByGang(getElementData(source, "gang"))) do
      if getElementData(player, "gang") == "None" then
        break
      end
      if getElementData(player, "gang") == getElementData(source, "gang") then
        outputChatBox("[GROUP]" .. getPlayerName(source) .. ": " .. message, player, 22, 255, 22, true)
      end
    end
  end
end
addEventHandler("onPlayerChat", getRootElement(), groupChat)
function refreshPlayerGangMemberList()
  local gangmembertable = {}
  local account = getPlayerAccount(source)
  local gang = getAccountGang(getAccountName(account))
  if gang == "None" then
    return
  end
  for i, gangmember in pairs(getGangMembers(gang)) do
    local groupleader = getGangLeader(gang)
    gangleader = false
    if gangmember.member_account == groupleader then
      gangleader = true
    end
    logedin = false
    if getAccountPlayer(getAccount(gangmember.member_account)) then
      logedin = true
      player = getAccountPlayer(getAccount(gangmember.member_account))
    end
    table.insert(gangmembertable, {
      gangmember.member_account,
      gangleader,
      logedin,
      player
    })
  end
  setElementData(getRootElement(), "gangmemberlist_" .. gang, gangmembertable)
end
addEvent("refreshPlayerGangMemberList", true)
addEventHandler("refreshPlayerGangMemberList", getRootElement(), refreshPlayerGangMemberList)
function refreshPlayerInvite()
  invited, gangName, inviter = isPlayerGangInvited(source)
  if invited then
    if not getElementData(source, "gang") == "None" then
      return
    end
    local gangmember = #getGangMembers(gangName)
    local gangvip = getGangSlots(gangName)
    triggerClientEvent(source, "updatePlayerInvites", source, gangName, getPlayerName(inviter), gangmember, gangvip)
  end
end
addEvent("refreshPlayerInvite", true)
addEventHandler("refreshPlayerInvite", getRootElement(), refreshPlayerInvite)
function acceptGroupInvite()
  invited, gangName, inviter = isPlayerGangInvited(source)
  if invited then
    if #getGangMembers(getElementData(inviter, "gang")) + 1 > getGangSlots(getElementData(inviter, "gang")) then
      outputChatBox(getPlayerName(source) .. ", #22ff22 this Group is full.", source, 22, 255, 22, true)
      return
    end
    addGangMember(gangName, getAccountName(getPlayerAccount(source)), "Leader")
    outputChatBox(getPlayerName(source) .. " #22ff22 joined the Gang " .. gangName .. ".", getRootElement(), 22, 255, 22, true)
  end
end
addEvent("acceptGroupInvite", true)
addEventHandler("acceptGroupInvite", getRootElement(), acceptGroupInvite)
function destroyGroup()
  local groupleader = getGangLeader(getElementData(source, "gang"))
  if getAccountName(getPlayerAccount(source)) == groupleader then
    for i, gangmember in pairs(getGangMembers(getElementData(source, "gang"))) do
      removeGangMember(getAccountGang(getAccount(gangmember.member_account)), gangmember.member_account)
    end
    outputChatBox(getPlayerName(source) .. " #22ff22 destroyed his Gang " .. getElementData(source, "gang"), getRootElement(), 22, 255, 22, true)
    removeGang(getAccountGang(getAccountName(getPlayerAccount(source))))
  else
    outputChatBox(getPlayerName(source) .. " #22ff22 you can't destroy this Gang.", source, 22, 255, 22, true)
  end
end
addEvent("destroyGroup", true)
addEventHandler("destroyGroup", getRootElement(), destroyGroup)
function leaveGroup()
  if getElementData(source, "gang") == "None" then
    return
  end
  local groupleader = getGangLeader(getElementData(source, "gang"))
  if getAccountName(getPlayerAccount(source)) == groupleader then
    outputChatBox(getPlayerName(source) .. ", #22ff22 you can't leave your own Gang.", source, 22, 255, 22, true)
    return
  end
  outputChatBox(getPlayerName(source) .. " #22ff22 left the Gang " .. getElementData(source, "gang") .. ".", getRootElement(), 22, 255, 22, true)
  removeGangMember(getAccountGang(getAccountName(getPlayerAccount(source))), getAccountName(getPlayerAccount(source)))
end
addEvent("leaveGroup", true)
addEventHandler("leaveGroup", getRootElement(), leaveGroup)
function kickGroupMember(playerName)
  if getElementData(source, "gang") == "None" then
    return
  end
  if string.find(playerName, "(Leader)") then
    return
  end
  local groupleader = getGangLeader(getElementData(source, "gang"))
  if getAccountName(getPlayerAccount(source)) == groupleader or isGangSubLeader(getElementData(source, "gang"), getAccountName(getPlayerAccount(source))) then
    outputChatBox(playerName .. ", #22ff22 was kicked from " .. getElementData(source, "gang") .. ".", getRootElement(), 22, 255, 22, true)
    removeGangMember(getElementData(source, "gang"), playerName, getPlayerName(source))
  else
    outputChatBox(getPlayerName(source) .. ", #22ff22 you can't kick Members.", source, 22, 255, 22, true)
  end
end
addEvent("kickGroupMember", true)
addEventHandler("kickGroupMember", getRootElement(), kickGroupMember)
function addGroupSubLeader(playerName)
  if getElementData(source, "gang") == "None" then
    return
  end
  if string.find(playerName, "(Leader)") then
    return
  end
  local groupleader = getGangLeader(getElementData(source, "gang"))
  if getAccountName(getPlayerAccount(source)) == groupleader then
    if not getAccountPlayer(getAccount(playerName)) then
      outputChatBox(playerName .. ", #22ff22 need's to be online.", source, 22, 255, 22, true)
      return
    end
    triggerEvent("gangSystem:addSubLeader", source, getPlayerName(getAccountPlayer(getAccount(playerName))))
    outputChatBox(playerName .. " #22ff22 is now a Subleader.", source, 22, 255, 22, true)
    outputChatBox("You are now a Subleader.", getAccountPlayer(getAccount(playerName)), 22, 255, 22, true)
  else
    outputChatBox(getPlayerName(source) .. ", #22ff22 you are not the Group Leader.", source, 22, 255, 22, true)
  end
end
addEvent("addGroupSubLeader", true)
addEventHandler("addGroupSubLeader", getRootElement(), addGroupSubLeader)
function removeGroupSubLeader(playerName)
  if getElementData(source, "gang") == "None" then
    return
  end
  if string.find(playerName, "(Leader)") then
    return
  end
  local groupleader = getGangLeader(getElementData(source, "gang"))
  if getAccountName(getPlayerAccount(source)) == groupleader then
    if not getAccountPlayer(getAccount(playerName)) then
      outputChatBox(playerName .. ", #22ff22 need's to be online.", source, 22, 255, 22, true)
      return
    end
    if isGangSubLeader(getElementData(source, "team"), playerName) then
      triggerEvent("gangSystem:removeSubLeader", source, getPlayerName(getAccountPlayer(getAccount(playerName))))
      outputChatBox(playerName .. ", #22ff22 is now no more Subleader.", source, 22, 255, 22, true)
    else
      outputChatBox(playerName .. ", #22ff22 is no Sub Leader.", source, 22, 255, 22, true)
    end
  else
    outputChatBox(getPlayerName(source) .. ", #22ff22 you are not the Group Leader.", source, 22, 255, 22, true)
  end
end
addEvent("removeGroupSubLeader", true)
addEventHandler("removeGroupSubLeader", getRootElement(), removeGroupSubLeader)
function invitePlayerToGroup(playerName)
  if getElementData(source, "gang") == "None" then
    return
  end
  local groupleader = getGangLeader(getElementData(source, "gang"))
  if getAccountName(getPlayerAccount(source)) == groupleader then
    if #getGangMembers(getElementData(source, "gang")) + 1 < getGangSlots(getElementData(source, "gang")) then
      if not getPlayerFromName(playerName) == false then
        if getElementData(getPlayerFromName(playerName), "gang") == "None" then
          triggerEvent("gangSystem:invitePlayer", source, playerName)
        else
          outputChatBox(playerName .. ", #22ff22 is already in a Gang.", source, 22, 255, 22, true)
        end
      else
        outputChatBox(playerName .. ", #22ff22 is not online.", source, 22, 255, 22, true)
      end
    else
      outputChatBox(getPlayerName(source) .. ", #22ff22 your Group is full.", source, 22, 255, 22, true)
    end
  else
    outputChatBox(getPlayerName(source) .. ", #22ff22 you need to be Leader.", source, 22, 255, 22, true)
  end
end
addEvent("invitePlayerToGroup", true)
addEventHandler("invitePlayerToGroup", getRootElement(), invitePlayerToGroup)
function gangcreateCommandHandler(cmd)
  if cmd == "creategang" then
    cancelEvent()
  elseif cmd == "accept" then
    cancelEvent()
    outputChatBox("Use the F1 panel to accept your Invite.", source, 255, 255, 255, true)
  elseif cmd == "gangs" then
    cancelEvent()
  end
end
addEventHandler("onPlayerCommand", getRootElement(), gangcreateCommandHandler)
function isGangExisting(gangname)
  for i, group in pairs(getGangList()) do
    if group.gang_name == gangname then
      return true
    end
  end
  return false
end
function createGroupForPlayer(playersource, command, ...)
  local teamName = table.concat({
    ...
  }, " ")
  if not isGuestAccount(getPlayerAccount(playersource)) and getElementData(playersource, "gang") == "None" then
    if teamName then
      if not isGangExisting(teamName) then
        addGang(teamName, getAccountName(getPlayerAccount(playersource)))
        setAccountData(getPlayerAccount(playersource), "gangslots", 12)
        outputChatBox("#FFFFFFYou created the group " .. teamName .. ".", playersource, 27, 89, 224, true)
      else
        outputChatBox("#FFFFFFThis Group is already existing.", playersource, 27, 89, 224, true)
      end
    else
      outputChatBox("#FFFFFFSyntax is /creategroup name.", playersource, 27, 89, 224, true)
    end
  else
    outputChatBox("#FFFFFFYou are already in a Group. ", playersource, 27, 89, 224, true)
  end
end
addCommandHandler("creategroup", createGroupForPlayer)
function setGroupVIP(playersource, command, targetString, moreSlots)
  if isObjectInACLGroup("user." .. getAccountName(getPlayerAccount(playersource)), aclGetGroup("Admin")) then
    if getAccount(targetString) then
      local oldData = getAccountData(getAccount(targetString), "gangslots") or 0
      setAccountData(getAccount(targetString), "gangslots", oldData + moreSlots)
      outputChatBox(targetString .. "'s Group is now a vip group with " .. getAccountData(getAccount(targetString), "gangslots") .. " Slots.", getRootElement(), 22, 255, 22, true)
    end
  else
    outputChatBox("#FFFFFFYou are not Admin. ", playersource, 27, 89, 224, true)
  end
end
addCommandHandler("givevip", setGroupVIP)
