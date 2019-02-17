// replace the default admonitions block with one that looks like the antora output to apply similar styling via adoc.css
$(document).ready(function () {
  function getAdmonitionType (elm) {
    return elm.classList[1]
  }
  function getAdmonitionText (elm) {
    return elm.getElementsByTagName('p')[0].innerHTML
  }

  const admonitions = document.getElementsByClassName('admonition-block')
  for (let i = admonitions.length - 1; i >= 0; i--) {
    const elm = admonitions[i]
    const type = getAdmonitionType(elm)
    const text = getAdmonitionText(elm)
    const parent = elm.parentNode
    const tempDiv = document.createElement('div')
    tempDiv.innerHTML = `<div class="admonitionblock ${type}">
    <table>
      <tbody>
        <tr>
          <td class="icon">
            <i class="fa icon-${type}" title="${type}"></i>
          </td>
          <td class="content">
            ${text}
          </td>
        </tr>
      </tbody>
    </table>
  </div>`

    const input = tempDiv.childNodes[0]
    parent.replaceChild(input, elm)
  }
})
