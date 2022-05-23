import { LightningElement, api } from "lwc";

export default class PreviewFile extends LightningElement {
  @api file;
  @api recordId;
  @api thumbnail;

  get iconName() {
    if (this.file.fileExtension) {
      switch (this.file.fileExtension) {
        case "png":
        case "jpg":
        case "jpeg":
        case "gif":
          return "doctype:image";
        case "pdf":
          return "doctype:pdf";
        case "xls":
        case "xlsx":
          return "doctype:excel";
        case "csv":
          return "doctype:csv";
        case "txt":
          return "doctype:txt";
        case "xml":
          return "doctype:xml";
        case "doc":
        case "docx":
        case "docm":
          return "doctype:doc";
        case "zip":
          return "doctype:zip";
        case "rtf":
          return "doctype:rtf";
        case "psd":
          return "doctype:psd";
        case "html":
          return "doctype:html";
        case "gdoc":
          return "doctype:gdoc";
        default:
          return "doctype:unknown";
      }
    }

    return "doctype:unknown";
  }

  /*get iconName() {
    if (this.file.fileExtension) {
      if (this.file.fileExtension === "pdf") {
        return "doctype:pdf";
      }
      if (this.file.fileExtension === "ppt") {
        return "doctype:ppt";
      }
      if (
        this.file.fileExtension === "xls" ||
        this.file.fileExtension === "xlsx"
      ) {
        return "doctype:excel";
      }
      if (this.file.fileExtension === "csv") {
        return "doctype:csv";
      }
      if (this.file.fileExtension === "txt") {
        return "doctype:txt";
      }
      if (this.file.fileExtension === "xml") {
        return "doctype:xml";
      }
      if (this.file.fileExtension === "doc") {
        return "doctype:word";
      }
      if (this.file.fileExtension === "zip") {
        return "doctype:zip";
      }
      if (this.file.fileExtension === "rtf") {
        return "doctype:rtf";
      }
      if (this.file.fileExtension === "psd") {
        return "doctype:psd";
      }
      if (this.file.fileExtension === "html") {
        return "doctype:html";
      }
      if (this.file.fileExtension === "gdoc") {
        return "doctype:gdoc";
      }
      if (
        this.file.fileExtension === "png" ||
        this.file.fileExtension === "jpg" ||
        this.file.fileExtension === "jpeg" ||
        this.file.fileExtension === "gif"
      ) {
        return "doctype:image";
      }
    }

    return "doctype:unknown";
  }*/

  get isDocTypeUnknown() {
    return this.iconName === "doctype:unknown";
  }

  get isPreviewable() {
    return (
      this.iconName === "doctype:image" ||
      this.iconName === "doctype:pdf" ||
      this.iconName === "doctype:txt"
    );
  }
}
