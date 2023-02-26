#include<stdio.h>
#include<string.h>
#include<fstream>
#include<iostream>
using namespace std;
ofstream outtfile;
class SymbolInfo
{
private :
    string name;
    string type;
    SymbolInfo *next;
public:
    SymbolInfo(string symname,string symtype)
    {
        name=symname;
        type=symtype;
        next=NULL;
    }
    SymbolInfo()
    {

    }
    void setname(string symname)
    {
        name=symname;
    }
    void settype(string symtype)
    {
        type=symtype;
    }
    string getname()
    {
        return name;
    }
    string gettype()
    {
        return type;
    }
    void setnext(SymbolInfo *sym)
    {
        next=sym;
    }
    SymbolInfo* getnext()
    {
        return next;
    }
    ~SymbolInfo()
    {
        if(next)delete next;

    }
};
class ScopeTable
{
private:
    int noofbuckets;
    SymbolInfo **table;
    string id;
    int childtablecounti=0;
    ScopeTable *parent;

public:
    ScopeTable(int num)
    {
        childtablecounti=childtablecounti+1;
        noofbuckets=num;
        table=new SymbolInfo*[noofbuckets];
        for(int i=0; i<noofbuckets; i++)
        {
            table[i]=NULL;
        }
        parent=NULL;
    }

    int Hashfunction(string tempname)
    {
        long long int sum_ascii=0;
        int idx;
        for(int i=0; tempname[i]!='\0'; i++)
        {

            sum_ascii=sum_ascii+tempname[i];

        }
        idx=sum_ascii%noofbuckets;
        return idx;
    }
    bool Insert(SymbolInfo *sym)
    {

        if(sym!=NULL)
        {
            int pos=0;
            int idx=Hashfunction(sym->getname());
            SymbolInfo *t=table[idx];
            if(table[idx]==NULL)
            {
                table[idx]=sym;
                

            }
            else
            {
                SymbolInfo *curr=new SymbolInfo()  ;
                while(t!=NULL)
                {
                    curr=t;
                    t=t->getnext();
                    pos=pos+1;
                }
                curr->setnext(sym);
                
            }
            return true;
        }
        else return false;
    }
    bool Delete(string name)
    {

        int idx=Hashfunction(name);
        SymbolInfo *prev=new SymbolInfo();
        SymbolInfo *curr=table[idx];
        if(curr!=NULL)
        {
            //cout<<"in delete"<<endl;
            int pos=0;
            while(curr->getname()!=name)
            {
                prev=curr;
                curr=curr->getnext();
                pos=pos+1;
            }
            if(pos==0)
            {
                table[idx]=table[idx]->getnext();

            }
            else
            {
                prev->setnext(curr->getnext());


            }
            
            return true;
        }
        else return false;
    }
    SymbolInfo* Lookup(string name)
    {
        int idx=Hashfunction(name);
        int pos=0;
        SymbolInfo *it=table[idx];
        while(it!=NULL)
        {
            //cout<<table[idx]->getname()<<endl;
            if(it->getname()==name)
            {
                
                return it;
            }
            it=it->getnext();
            pos=pos+1;
        }
        //cout<<"Not Found"<<endl;
        return NULL;
    }
    void print(FILE *t)
    {
    	FILE *logout;
    	logout=t;
        fprintf(logout,"Scopetable # %s\n",getid().c_str());
      
        for(int i=0; i<noofbuckets; i++)
        {
            if(table[i]!=NULL){
            fprintf(logout,"%d-->",i);
            SymbolInfo *t=table[i];
            while(t!=NULL)
            {
                
                fprintf(logout," < %s : %s >",t->getname().c_str(),t->gettype().c_str());
                t=t->getnext();
            }
            //cout<<"here"<<endl;
            fprintf(logout,"\n");
        }
        }
    }
    void setid()
    {
        if(parent==NULL) id="1";
        else id=parent->getid()+"."+to_string(parent->getchildtablecount());

    }
    string getid()
    {
        return id;
    }
    void setparent(ScopeTable *st)
    {
        parent=st;
    }
    ScopeTable* getparent()
    {
        return parent;
    }
    int getchildtablecount()
    {
        return childtablecounti;
    }
    void increasecount()
    {
        childtablecounti=childtablecounti+1;
    }
    ~ScopeTable()
    {
        if(table)
        {
            for(int i=0; i<noofbuckets; i++)
            {
                delete(table[i]);
            }
            delete []table;
            //delete parent;
        }
    }

};
class SymbolTable
{
private:
    ScopeTable *current;
    int total_bucket;
    int counti=1;
public:
    SymbolTable(int num)
    {
        total_bucket=num;
        current=NULL;
        ScopeTable *newone=new ScopeTable(total_bucket);
        newone->setparent(current);
        newone->setid();
        current=newone;
    }
    void Enter()
    {
        ScopeTable *newone=new ScopeTable(total_bucket);
        newone->setparent(current);
        newone->setid();
        current=newone;
    }
    void Exit()
    {
        current->getparent()->increasecount();
        ScopeTable *temp=current->getparent();
        delete current;

        current=temp;
    }
    bool Insert(string name,string type)
    {

        if(current->Lookup(name))
        {
            
            return false;
        }
        else
        {
            SymbolInfo *newsymbol=new SymbolInfo(name,type);
            return current->Insert(newsymbol);

        }

    }
    bool Remove(string name)
    {
        if(current->Lookup(name)==NULL)
        {
            
            return false;
        }
        else
        {
            return current->Delete(name);

        }
    }
    SymbolInfo* Lookup(string name)
    {
        ScopeTable *temp=current;
        while(temp!=NULL)
        {
            //cout<<"hereeee"<<endl;
            SymbolInfo *t=temp->Lookup(name);
            if(t!=NULL)
            {
                return t;
            }
            else
            {
                temp=temp->getparent();
            }
        }
        return NULL;
    }
    void printcurrent(FILE *tee)
    {
        FILE *logout=tee;
        current->print(logout);
        outtfile<<endl;
    }
    void printall(FILE *tt)
    {
    	FILE *logout=tt;
        ScopeTable *temp=current;
        //cout<<current->getid()<<endl;
        while(temp!=NULL)
        {
            //cout<<temp->getid()<<endl;
            temp->print(logout);
            fprintf(logout,"\n");
            temp=temp->getparent();
        }
    }
    ~SymbolTable()
    {
        if(current)
        {
            ScopeTable *curr=current;
            while(curr!=NULL)
            {
                ScopeTable *temp=curr;
                delete temp;
                curr=curr->getparent();
            }
        }
    }

};
/*int main()
{
    //SymbolInfo *s=new SymbolInfo("123","int");
    //int linecount=1;
    ifstream myfile("input.txt");
    outtfile.open("output.txt");
    //outtfile.open("output.txt");

    if(myfile.is_open())
    {

        int num;
        char indi;
        string name;
        string type;
        char indi2;
        myfile>>num;
        SymbolTable st(num);
        while(!myfile.eof())
        {
            myfile>>indi;
            if(myfile.eof())break;
            cout<<indi<<" ";
            outtfile<<indi<<" ";

            //cout<<indi<<endl;
            if(indi=='I')
            {
                myfile>>name;
                cout<<name<<" ";
                outtfile<<name<<" ";
                myfile>>type;
                cout<<type<<" "<<endl;
                outtfile<<type<<" "<<endl;
                cout<<endl;
                outtfile<<endl;
                st.Insert(name,type);
                cout<<endl;
                outtfile<<endl;

            }
            else if(indi=='L')
            {
                myfile>>name;
                cout<<name<<endl;
                outtfile<<name<<endl;
                cout<<endl;
                outtfile<<endl;
                st.Lookup(name);
                //cout<<endl;
                //outtfile<<endl;

            }
            else if(indi=='D')
            {
                myfile>>name;
                cout<<name<<endl;
                outtfile<<name<<endl;
                cout<<endl;
                outtfile<<endl;
                st.Remove(name);
                cout<<endl;
                outtfile<<endl;
            }
            else if(indi=='P')
            {
                myfile>>indi2;
                cout<<indi2<<endl;
                outtfile<<indi2<<endl;
                cout<<endl;
                outtfile<<endl;
                if(indi2=='A') st.printall();
                else st.printcurrent();


            }
            else if(indi=='S')
            {
                cout<<endl;
                outtfile<<endl;
                cout<<endl;
                outtfile<<endl;
                st.Enter();
                cout<<endl;
                outtfile<<endl;
            }
            else if(indi=='E')
            {
                cout<<endl;
                outtfile<<endl;
                cout<<endl;
                outtfile<<endl;
                st.Exit();
                cout<<endl;
                outtfile<<endl;
            }
            else break;
        }

    }
    else cout<<"File can't be opened"<<endl;
    return 0;
}*/
