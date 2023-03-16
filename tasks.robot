*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Desktop
Library             RPA.PDF
Library             Collections
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    Loop the orders    ${orders}
    Create a ZIP file of receipt PDF files


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${table}=    Read table from CSV    orders.csv
    RETURN    ${table}

Loop the orders
    [Arguments]    ${orders}
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${order}
        Preview the robot    ${order}
        Submit the order

        ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
        ${screenshot}=    Take a screenshot    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}

        Order another robot
    END

Close the annoying modal
    Click Button    css:button.btn.btn-dark

Fill the form
    [Arguments]    ${order}
    Select From List By Value    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    css:input[placeholder="Enter the part number for the legs"]    ${order}[Legs]
    Input Text    id:address    ${order}[Address]

Preview the robot
    [Arguments]    ${order}
    Click Button    id:preview
    Wait Until Element Is Visible    css:img[alt="Legs"]

Submit the order
    Wait Until Keyword Succeeds    5x    1s    Click order and show receipt

Click order and show receipt
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}receipts${/}${order_number}.pdf
    RETURN    ${OUTPUT_DIR}${/}receipts${/}${order_number}.pdf

Take a screenshot
    [Arguments]    ${order_number}
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}screenshots/${order_number}.png
    RETURN    ${OUTPUT_DIR}${/}screenshots/${order_number}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Close Pdf

Order another robot
    Click Button    id:order-another

Create a ZIP file of receipt PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/receipts.zip
    Archive Folder With Zip
    ...    ${OUTPUT_DIR}${/}receipts
    ...    ${zip_file_name}
