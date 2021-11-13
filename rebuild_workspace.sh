#!/bin/sh

WORKSPACE_DIR="Apple.xcworkspace"
REPOS_DIR=Repos

print_head()
{
    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    echo "<Workspace\n   version = \"1.0\">"
}

print_tail()
{
    echo "</Workspace>"
}

append_file_ref() 
{
    PACKAGE_NAME=$1
    echo "   <FileRef\n      location = \"group:${REPOS_DIR}/${PACKAGE_NAME}\">"
    echo "   </FileRef>"
}

find_and_append_project() 
{
    PACKAGE_NAME=$1
    PROJECTS=$(ls ${REPOS_DIR}/${PACKAGE_NAME} | grep -v Tests | grep .xcodeproj)
    for PROJECT in ${PROJECTS}; do
        if [ ! -z "${PROJECT}" ]; then
            append_file_ref "${PACKAGE_NAME}/${PROJECT}"
        fi
    done
}

read_package()
{
    PACKAGE_NAME=$1
    # echo $PACKAGE_NAME
    if [ -f "${REPOS_DIR}/${PACKAGE_NAME}/Package.swift" ]; then
        append_file_ref ${PACKAGE_NAME}
    elif [ -d "${REPOS_DIR}/${PACKAGE_NAME}/${PACKAGE_NAME}.xcodeproj" ]; then
        append_file_ref "${PACKAGE_NAME}/${PACKAGE_NAME}.xcodeproj"
    else
        find_and_append_project ${PACKAGE_NAME}
    fi
}

read_packages()
{
    for DIR in `find ${REPOS_DIR} -type d -maxdepth 1`; do
        PACKAGE_NAME=$(basename ${DIR})
        if [ "${REPOS_DIR}" != "${PACKAGE_NAME}" ]; then
            read_package "${PACKAGE_NAME}"
        fi
    done
}

generate_workspace()
{
    print_head
    read_packages
    print_tail
}

rebuild_workspace()
{
    mkdir -p "${WORKSPACE_DIR}"
    generate_workspace > "${WORKSPACE_DIR}/contents.xcworkspacedata"
}

rebuild_workspace
# read_packages
