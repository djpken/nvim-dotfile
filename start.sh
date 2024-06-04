#!/bin/bash

file_name=/nvim
source_file=./
dest_file=~/.config
local_sync() {
    cp -r "$source_file$file_name" "$dest_file"
    cp_exit_code=$?

    # Check if rsync was successful
    if [ $cp_exit_code -ne 0 ]; then
        echo "cp error: some files could not be transferred. Exit code: $cp_exit_code"
        exit $cp_exit_code
    else
        echo "Synchronization of nvim completed and the configuration has been reloaded."
    fi
}
git_sync() {
    cp -r "$dest_file$file_name" "$source_file"
    cp_exit_code=$?

    # Check if cp was successful
    if [ $cp_exit_code -ne 0 ]; then
        echo "cp error: some files could not be transferred. Exit code: $cp_exit_code"
        exit $cp_exit_code
    else
        echo "Synchronization of nvim from local completed."
    fi
}
remove(){
    rm -r "$dest_file$file_name"
    rm_exit_code=$?

    # Check if cp was successful
    if [ $rm_exit_code -ne 0 ]; then
        echo "rm error: some files could not be transferred. Exit code: $rm_exit_code"
        exit $rm_exit_code
    else
        echo "Remove successful. "
    fi
}
while true; do
    echo "Please choose:"
    echo "1) Local sync by Git"
    echo "2) Git sync by Local" 
    echo "3) Local remove "
    echo "4) Exit"
    read -p "Input option (1-4): " choice

    case $choice in
        1)
            echo "Loading Local sync..."
            local_sync
            ;;
        2)
            echo "Loading Git sync..."
            git_sync
            ;;
        3)
            echo "Loading Local remove..."
            remove
            ;;
        4)
            echo "Exit"
            break
            ;;
        *)
            echo "Option is wrong，please enter again"
            ;;

    esac
    echo ""
done

